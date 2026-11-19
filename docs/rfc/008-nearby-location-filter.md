# RFC 008: The location filter: Nearby and City

Status: Accepted · Updated: 2026-11-19 · Code: `Sources/Site/Music` (`NearbyModel`, `LocationFilter`,
`CityResolver`, `VaultModel`, `NearbyDefaults`), `Sources/Site/Utility/LocationManager.swift`,
`Sources/Site/Music/UI` (`Nearby*`, `CityFilterView`, `CityNameField`, `LocationFilterToolbarContent`)

## Summary

The Shows, Venues and Artists tabs can be narrowed to the venues near the person, or to the venues
in a city. The filter chooses venues; everything else it shows (shows, artists, statistics, the
chart of years) follows from which venues are left. This RFC is the filter's state, how the
person's location and current city are found and kept, and what each state of the filter shows.
How a venue gets a place in Maps, which **Nearby** depends on, is RFC 002.

## State

| State | Is | Kept |
|---|---|---|
| `NearbyModel` | the filter (`none`, `nearby` or `city`), the mode it uses when on, and a typed city name | per scene, `@SceneStorage("nearby.state")` |
| Distance | how far counts as nearby, in meters; 10 miles by default | per app, `@AppStorage("nearby.distance")` |
| Location, authorization, current city | what the device says now | `VaultModel`, not saved |

### Rules

1. The mode MUST never be `none`. When the filter is on, the mode is the filter, and changing the
   mode while the filter is on changes the filter. Turning the filter on uses the mode, and
   turning it off remembers it.
2. Saved state without a mode (from an older build) MUST still decode, with `nearby`.
3. A typed city MUST NOT be stored when it is the current city, so a filter that follows the
   person's location keeps following it. A blank name means the same.
4. The slider's range follows the locale's measurement system (1 to 100 miles, or 1 to 150 km),
   but the stored distance is always meters.
5. Only Shows, Venues and Artists can be filtered. Today, Search and Settings never are, and show
   no filter control.

## What the filter selects

A filter becomes a set of venues, and the rest comes from that set: the shows at those venues,
the artists who played them, and the statistics and the counts by year of those shows. With the
filter off, every venue is selected, and the archive's own precomputed values are used (RFC 006).

6. **Nearby** selects the venues whose place in Maps is within the distance of the person.
   A venue with no place yet (not geocoded, or not found) is never nearby. Results grow as
   geocoding finishes, and a progress view says so while it does.
7. **City** selects the venues whose own city, in the archive's data, contains the city, ignoring
   case, diacritics and surrounding space. It uses no geocoding. The city is the typed one, or the
   current one when nothing is typed, and with neither no venue is selected.
8. Filtering MUST NOT change the archive's data or its rankings. A rank is the venue's rank in the
   whole archive, shown for the venues the filter leaves.

## Finding the person

`LocationManager` is an actor that wraps Core Location's live updates in an `AsyncThrowingStream`
of two events: `denied`, and a `location` that is far enough from the one before it (10 meters,
at hundred-meter accuracy). `VaultModel` listens for as long as it lives.

9. A denial MUST be reported once, until a location comes back. It clears the location, stops any
   city lookup, forgets the last attempt and the current city. Restricted and denied
   look the same to the person: "Location Unavailable".
10. Authorization is asked for when-in-use, and only if it hasn't been decided.
11. The location and city are for this session only. Nothing about where the person has been is
    saved, and the scene state holds only the filter and the typed name.

### The current city

The city comes from a reverse geocode of the location, through `CityResolver`. MapKit limits
reverse geocoding (RFC 002), so `ReverseGeocodePolicy` decides when a location asks:

| Location | Asks when |
|---|---|
| the first | always |
| 50 km or more from the last ask | at once |
| 1 km or more from the last ask | 60 seconds or more after it |
| any other | never |

12. A new ask MUST cancel the one before it, and a result that was cancelled MUST NOT be kept.
13. A lookup that finds no city, or fails, MUST leave the current city as it was. A throttled one
    is logged and isn't an error to show.

## What each state shows

| Filter | Condition | Shows |
|---|---|---|
| Nearby | not allowed | "Location Unavailable", pointing at Settings |
| Nearby | allowed, nothing selected | "Nothing Nearby", suggesting the distance or turning it off |
| Nearby | allowed, geocoding unfinished | the filtered list, with "Geocoding…" |
| City | no city | "No City": allow location or type one |
| City | a city, nothing selected | "Nothing in <city>" |

Over a map, the message is on a card, and the progress is a capsule floated at the top, so
neither pushes the map down.

## Rationale

- **The filter chooses venues.** Where a show is, and who played, are facts about its venue. One
  set of venues gives the same answer for every list and statistic.
- **Two modes, one switch.** The toolbar button toggles the filter, and the menu picks which
  mode it is, so one tap turns on whatever was last used.
- **Following the location.** A typed city is a choice; the current city is a default. Storing
  only the choice lets the filter move with the person until they decide.
- **A policy for reverse geocoding.** Location updates are frequent and the geocoder is limited.
  City names change slowly, so a move of a kilometre, at most once a minute, is enough, and a
  large jump is a new place and skips the wait.
- **Per scene and per app.** Two windows can filter differently. The distance is a preference.

## Open questions

- **When the prompt appears.** `VaultModel` starts listening when it is made, so the system
  asks for location at launch, before the filter has been turned on. Asking when the filter is
  first turned on would be less surprising, but would leave the current city empty until then.
- **A throttled city lookup.** The attempt is recorded before the request, so after a throttled
  one the policy waits for a move and the interval instead of trying again.
