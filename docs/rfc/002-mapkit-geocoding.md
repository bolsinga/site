# RFC 002: MapKit geocoding, identifiers and caching

Status: Accepted · Updated: 2026-11-17 · Code: `Sources/Site/Music` (`Atlas`, `AtlasCache`,
`Throttle`, `MapItemLookup`, `Placemark`), `Sources/Site/VenuePlaces`

## Summary

The app places venues in Apple Maps by geocoding their addresses and by looking up MapKit place
identifiers. Maps limits how often an app may ask, and its answers change over time, so every
request is queued behind a throttle and every answer is cached. Part 1 is the general approach,
independent of this app. Parts 2 and 3 are how the site app and Venue Places apply it.

# Part 1: General approach

## What MapKit gives

1. **Geocoding.** `MKGeocodingRequest(addressString:)` turns an address into map items; the first is
   the best match. `MKReverseGeocodingRequest(location:)` goes the other way, to a city or address.
2. **Place identifiers.** A map item may have an `MKMapItem.Identifier`. Apple documents that it can
   be persisted and used later to recall the place, with `MKMapItemRequest(mapItemIdentifier:)`.
   Apple also documents that a point of interest's identifier **may change over time**;
   `MKMapItem.alternateIdentifiers` lists the other identifiers for the same place.
3. **Other lookups.** `MKMapItemRequest(placeDescriptor:)` (GeoToolbox) resolves a name and address
   to a place. `MKLocalSearch` finds places by text, or by category near a point.
4. **Throttling.** Making many requests in a short time fails with `MKError.loadingThrottled`.
   MapKit states the limit in the message of the error it logs when it throttles, not in the API
   documentation; the figure here, 50 requests per 60 seconds for each kind of request, was read
   from that message. If the message changes, so does the limit.
5. **No result is not an error.** An address or identifier Maps can't find fails with
   `MKError.placemarkNotFound`, which is different from being throttled.

## Rules

1. Every MapKit request that can be repeated per item MUST go through a throttle that allows no
   more than the limit in each window. Code MUST NOT call MapKit directly in a loop.
2. A throttled failure MUST wait out the window and retry the same item. A not-found failure MUST
   NOT be retried in the same run, and MUST NOT stop the items after it.
3. Throttling MUST be shared by every caller of the same kind of request, so two features can't
   each use the full limit.
4. Prefer a stored identifier to an address: it names the place, where an address only finds the
   likeliest one. When an identifier fails to resolve, fall back to the address, and try the
   identifier again later.
5. A cached answer MUST record what it was computed from. When that changes, the answer is stale,
   and a stale answer MAY still be shown until its replacement arrives.
6. A cached answer MUST also expire. Maps changes without the app's data changing: a place closes,
   or gets a new identifier. Expiry SHOULD be staggered so entries added together don't all become
   due together.
7. A failed request MUST NOT be cached as an answer, unless it is a definite "not found". When
   every attempt in a group fails, nothing is saved, so an outage isn't taken for "no place".

## Rationale

- **Identifier first.** Geocoding an address often lands on the center of a city, or on another
  business at the same address. An identifier doesn't have that ambiguity.
- **Source, then age.** Recording what an answer was computed from catches a change in the inputs
  at once. Expiry catches a change at Maps' end, which nothing in the inputs would show.
- **Not the archive's date.** The archive's modified date changes whenever any data in it does,
  which would discard every answer after each update.
- **Alternate identifiers** can tell a replaced identifier for the same place from one that now
  names a different place. This isn't used yet.

# Part 2: The site app

## Where it lives

- `String.geocode()` (`Geocode.swift`) makes the geocoding request and returns a `Placemark`.
- `Placemark` is what's kept for a venue: `.coordinate` (where an address is, with the address
  Maps gave as `MapsAddress`), `.identifier` (a place to look up), or `.place` (an identifier with
  where it is, so showing it needs no lookup).
- `Venue.geocode()` (`Venue+Geocodable.swift`) uses the venue's MapKit identifier when it has one,
  and its address otherwise or when the identifier fails.
- `Atlas<T>` (`Atlas.swift`) geocodes an item, behind a `Throttle` and an `AtlasCache`.
- `BatchGeocode` runs `Atlas` over many items.
- `MapItemLookup` is the one place that resolves an identifier.
- `NSError+Geocoding.swift` classifies a failure as throttled or not found.

## Rules

1. `Throttle` allows `MapKitLimits.maxRequests` (50) in each `MapKitLimits.timeUntilReset` (60 s).
   `Atlas` throttles geocoding, and `VaultModel` the reverse geocode of the current city (a
   kind of its own, [RFC 008](008-nearby-location-filter.md)). `MapItemLookup` throttles identifier lookups with its own window,
   five seconds longer, since MapKit's window starts a little after the app's. Anything that
   repeats a request for many venues MUST go through these. A single request a person asks for,
   such as Find Places on a venue's page, calls MapKit directly.
2. A throttled error pauses the throttle until the window resets and retries. A not-found error
   ends that item with no place and the batch goes on. Any other error stops the batch.
3. The cache is `atlas.json` in the Caches directory, one entry per venue ID. An entry is dropped
   on load once its expiry has passed. Expiry is six months, plus six hours for each entry added
   in a run, so a batch doesn't all expire at once.
4. An entry records `Venue.geocodeSource`: the venue's address and MapKit identifier. It is
   unusable (`canUseCached`) when the source differs; when the venue has an identifier and the
   entry isn't the place for it; and when the entry has no address from Maps, so older entries
   are found again once to keep it.
5. `BatchGeocode` returns the cached answers first so they show at once, then geocodes what was
   never cached, then those whose cached answer is stale, returning each with its new answer. When
   a stale entry can't be found again, the old one stays and a later run tries again.
6. `VaultModel` runs the batch after the archive loads. It keeps each venue's map item and the
   address Maps gave for the session. `geocodingInProgress` is true until the batch completes, and
   a cancelled batch MUST NOT report that it completed.
7. Reverse geocoding (the user's city) is separate. `ReverseGeocodePolicy` allows a request after a
   move of more than 1 km, and no more than once a minute, unless the move is more than 50 km.

# Part 3: Venue Places

## Rules

1. Venue Places MUST reuse `Atlas` and `BatchGeocode` for what it checks, with `cache: nil`, so a
   check is throttled but doesn't go into `atlas.json`. It MUST use `MapItemLookup` for place
   cards.
2. **Verifying** resolves the identifier a venue has, picked or the archive's (`SavedPlace`). The
   result is verified, replaced by another identifier, or not found.
3. **Suggesting** (`VenueCandidateSearch`) makes up to three requests for a venue without an
   identifier: Maps' best guess for the name and address (`placeDescriptor`), a text search near
   where the venue geocodes, and, when it has a street, nearby points of interest of venue-like
   categories. If every request fails, nothing is saved.
4. Results are kept in `venue-checks.json` and `venue-suggestions.json` in the Caches directory,
   like `atlas.json`, each with the date it was checked. A verification is keyed by the identifier
   it resolved; a suggestion by the venue's name and address. A result is asked again when its key
   changes, when it is older than `CacheAge.maximum` (30 days), or when it has no date.
5. Maps' answers about a place MUST NOT change what the venue has unless a person chooses it. See
   [RFC 001](001-venue-places.md).

## Rationale

- **Two cache lifetimes.** Where an address is rarely changes, so geocodes last six months.
  Whether a place still exists, or kept its identifier, changes more often, and Venue Places is
  there to catch that, so its results last 30 days. The 30 days is one constant,
  `CacheAge.maximum`.
- **Caches directory.** These are answers that can be asked for again, so the system may remove
  them when it needs space. The cost is that the next run asks again, through the throttle. Edits
  a person made are not caches and are never kept there; see [RFC 001](001-venue-places.md).
- **Not in `atlas.json`.** What Venue Places asks is about one venue's place, not where its
  address is, and its results are keyed differently, so they live in their own files.

## Non-goals

- A request quota shared across devices. The limit is per device.
- Using alternate identifiers to tell a replaced identifier from a different place.

## Open questions

None.
