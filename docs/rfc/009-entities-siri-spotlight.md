# RFC 009: App Intents entities, Siri and Spotlight

Status: Accepted · Updated: 2026-11-19 · Code: `Sources/Intents`, `Sources/Site/Music/VaultModel.swift`,
`Sources/Site/Music/*+NSUserActivity.swift`, `Sources/Site/Music/SiteModel.swift`

## Summary

The app describes its archive to the system as App Intents entities, so Siri, Shortcuts and
Spotlight can find an artist, a venue or a concert and open it, or answer a question about it
without opening the app. An entity is a read-only view of one archive item, identified by the
item's `ArchivePath`. Opening one is a URL, and goes through the same code as any other link
(RFC 003). This RFC is what is exposed, how the entities are built and queried, what the
shortcuts do, and how Spotlight is kept in step with the archive.

## What is exposed

| Type | Is | Id | Opens | Indexed |
|---|---|---|---|---|
| `ArtistEntity` | an artist | the `ArchivePath`'s raw ID | its page (`OpenArtist`) | yes |
| `VenueEntity` | a venue | the same | its page (`OpenVenue`) | yes |
| `ConcertEntity` | a show | the same | its page (`OpenConcert`) | yes |
| `CityEntity` | a city and state | `"City, State"` | nothing | no |
| `CategoryEnum` | Today, Shows, Venues or Artists | its raw value | the category (`OpenCategory`) | no |

### Rules

1. An entity's id MUST be the item's `ArchivePath` in its `.rawID` form (RFC 004), so an entity from
   Siri or Spotlight and the page the app shows are the same thing. A city has no page, and is
   named by its city and state, because a city name alone isn't unique.
2. `CategoryEnum`'s raw values are saved by the system in shortcuts, so they MUST NOT be renamed
   or reused. Settings and Search aren't offered.
3. An entity MUST carry the item's website URL, and `Open…` intents MUST be
   `URLRepresentableIntent`s, so opening is a URL and nothing in `Sources/Intents` knows about the
   app's navigation. An item whose URL can't be made has no entity.
4. `OpenCategory` returns an `OpenURLIntent` for the category's URL and opens the app.
5. Only `@Property` members are visible to the system. Values used to match a search, or to find
   a related entity (the venue and artist ids and names on a concert), are plain stored values.
6. What links to other entities (a concert's venue and artists, an artist's or venue's concerts)
   MUST be a `@DeferredProperty`, built when asked for, so an entity stays small.
7. A partial date is exposed as year, month and day with 0 for what is unknown, a flag, and a
   `date` that is the distant past unless every part is known, so a sort follows the calendar.

## Building and finding entities

Entities are made from the archive's digests by the `Vault` (`artistEntity(for:)` and the like),
which also supplies the URL, from what the digests (RFC 006) already hold.

8. Code that runs in an intent reads the archive through `@Dependency var vault: Vault`.
   `VaultModel` registers the `Vault` with `AppDependencyManager` when it is made.
9. A deferred property is asked for by the system outside of an intent, where `@Dependency` can't
   be read, so it uses `EntityVault.vault`, which `VaultModel` sets alongside. A load that is
   not for a preview MUST set both, and a newer load replaces them.
10. Every entity type has a query with these parts:
    - **By id.** The ids that exist, in the order asked.
    - **Suggested.** The artists, venues or concerts of today's date, or the five most recent
      when there are none.
    - **By string.** A localized, case and diacritic insensitive match on the name: the
      `Vault`'s own name search for artists and venues, and the venue or an artist for concerts.
    - **By property.** `EntityPropertyQuery` with comparators for the properties listed below,
      evaluated over every entity, and sorted before the limit is applied.

| Entity | Searchable properties | Sortable by |
|---|---|---|
| Artist | name, show count, venue count, related names | the same, except related |
| Venue | name, city, state, show count, artist count, related names | the same, except related |
| Concert | venue, artists, year, month, day, date, unknown date, artist count | date, artist count |
| City | every city, as a list, and by name | none |

## Shortcuts and Siri

`SiteShortcuts` gives Siri phrases for opening a category, for the concerts by an artist, at a
venue and in a city, and for today's concerts. The phrases are in `AppShortcuts.xcstrings`.

11. The app MUST call `updateAppShortcutParameters()` at launch, so phrases that name an artist, a
    venue or a city know the entities the archive has.
12. `ShowConcerts` and `ShowConcertsToday` answer: they return the concerts, a spoken count
    ("Found 3 concerts"), and a snippet of the first six, with "And N more". They MUST NOT open
    the app. A search narrows by any mix of artist, venue, city and date, and a part left out does
    not narrow (`ConcertSearch`).
13. "Today" is the day of the leap year, as in the app's Today screen.

## Spotlight

`indexForSpotlight()` puts every artist, venue and concert in a `CSSearchableIndex` named
`SiteApp`, as `IndexedEntity`s with the URL, and keywords from related names, venue addresses
and the artists and venue of a concert. It runs after each load that is not a preview, and not on
tvOS.

14. The index MUST record what it holds, as the client state of its last batch: the
    `spotlightIndexVersion` and the archive's `timestamp`. When that equals the current one,
    nothing is indexed.
15. `spotlightIndexVersion` MUST be bumped whenever what is indexed changes, so an index made by an
    older build is replaced.
16. A refresh is one batch: delete the three entity types, index them again, then end the batch
    with the new state. A failure, or a cancelled load, MUST end the batch with the old state,
    so the next load tries again.
17. When the system asks (`IndexedEntityQuery`), the ids named are indexed again, and ones the
    archive no longer has are deleted. A request for everything forces a full index.

## Onscreen content

The artist, venue and show pages set `appEntityIdentifier` on the view and on their
`NSUserActivity`, so Siri can act on what is showing. The activity gets it only when the page has
a URL, as the entity requires one.

## Rationale

- **The path as the id.** The website's IDs are stable across archive updates, and parsing one
  already exists for links. An entity, a link and a page are then one thing.
- **URL as the way to open.** The system's own open intents need nothing beyond the URL, and the
  app keeps one way to turn a URL into a screen.
- **Answer in the intent.** A question like "what shows were here today" is better answered with
  a list than by opening the app, so those intents return a value, dialog and snippet.
- **A stamp on the index.** Indexing everything is slow work. The stamp makes a launch on the same
  archive cost one read, and the version covers changes the archive's date can't show.

## Open questions

- **An intent before the first load.** The `Vault` is registered when the first `VaultModel` is
  made, after the archive has loaded. An intent that runs before then has no `Vault` to read.
  What the system does in that case isn't documented here.
- **Cities.** `CityEntity` is a parameter only. It isn't indexed, and has no page to open.
- **Whole-archive queries.** Searching by property, and the list of cities, build every entity
  of that type on each call, where the archive could hold them once per load.
