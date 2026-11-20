# RFC 011: Persisted state

Status: Accepted · Updated: 2026-11-19 · Code: `Sources/Site/Music/UI/ArchiveStateView.swift`,
`Sources/Site/Music/UI/SiteView.swift`, `Shared/Sources/Shared/Utilities/FileManager+CacheCodable.swift`,
`Shared/Sources/Shared/MusicData/Bracket.swift`, `Shared/Sources/Shared/Widget`,
`Sources/Site/Music/AtlasCache.swift`, `Sources/Intents/Vault+Spotlight.swift`

## Summary

The app keeps state in five kinds of place: the scene (`@SceneStorage`), the app's defaults
(`@AppStorage`), the Caches directory, the app group container, and the Spotlight index. This RFC
lists every one, who writes it, what retires it, and what happens when it can't be read. What is
inside each is in the RFC for the feature that owns it. Nothing in this app is saved that the
archive or the network can't give back, apart from the person's own choices.

## Inventory

### Per scene: `@SceneStorage`, in `ArchiveStateView`

| Key | Type | Is | RFC |
|---|---|---|---|
| `navigation.state` | `ArchiveNavigation`, as JSON | category and the path of each category | 004 |
| `nearby.state` | `NearbyModel`, as JSON | filter, mode, typed city | 008 |
| `venue.sort`, `artist.sort` | `RankingSort`, an `Int` enum | sort of the library lists | |
| `venues.mode` | `VenuesMode`, an `Int` enum | map or list | |
| `shows.sort.descending` | `Bool` | order of the shows list | |

### Per app: `@AppStorage`

| Key | Type | Default | Is |
|---|---|---|---|
| `nearby.distance` | `Double`, meters | `defaultNearbyDistanceThreshold`, 10 miles | how far counts as nearby ([RFC 008](008-nearby-location-filter.md)); read in four views |
| `music.last.modified` | `Date` | `.distantPast` | the archive's date at the last load, passed as `previousModified` ([RFC 005](005-music-loading.md)) |

### Files

| File | Where | Written by | Retired by | Unreadable |
|---|---|---|---|---|
| `bracket-<n>.json` (`bracket.json` for 1) | Caches | `Bracket.save`, after a download | `bracketCacheVersion`, 3 | cache failure: download ([RFC 005](005-music-loading.md), [006](006-precomputed-music-data.md)) |
| `atlas.json` | Caches | `AtlasCache`, on each geocode | six-month expiry per entry ([RFC 002](002-mapkit-geocoding.md)) | logged, starts empty |
| `venue-checks.json`, `venue-suggestions.json`, `venue-web-checks.json` | Caches | Venue Places `PickStore` (Debug, macOS) | `CacheAge.maximum` ([RFC 001](001-venue-places.md)) | left alone, not overwritten; Venue Places shows an error |
| `shows-today.json` | app group `group.gdb.SiteApp`, `Library/Application Support` | `ShowsTodaySnapshot.write` | `currentVersion`, 2 | no snapshot ([RFC 007](007-shows-today-widget.md)) |

### Elsewhere

- **Spotlight index "SiteApp".** Its client state is the stamp, `spotlightIndexVersion` (3) and the
  archive's timestamp ([RFC 009](009-entities-siri-spotlight.md)). A stamp that can't be fetched reads as empty, so it indexes again.
- **Venue Places window frame.** macOS saves it under the name `VenuePlaces` through AppKit's frame
  autosave (`WindowFrameAutosave`).

## Rules

1. State a person chose, or that returns them to where they were, MUST be in `@SceneStorage` or
   `@AppStorage`. A value that can be had again from the archive, the network or Maps MUST be in the
   Caches directory, which the system may purge, and MUST NOT be anywhere else. Code that keeps
   one takes a `CacheCodable`, so a test can use one that stays in memory.
2. State that differs by window (where it is, how it is filtered or sorted) MUST be per scene.
   A preference that isn't about one window (`nearby.distance`) MUST be per app. A new key MUST be
   named in the same dotted lowercase style.
3. Saved scene state MUST decode with `try?` and a failure MUST fall back to the default, never
   throw. `ArchiveNavigation` and `NearbyModel` return `nil` from `init?(rawValue:)` for it, which
   leaves `@SceneStorage` on its declared default. A field added to saved state MUST decode when
   absent (`NearbyModel.State.mode` does, with `nearby`), so an older scene still restores.
4. An enum saved by raw value (`RankingSort`, `VenuesMode`, `LocationFilter`) MUST NOT have its
   cases renumbered or reused.
5. A saved file whose meaning or shape changes MUST be retired, not read as it was. `Bracket` does it
   by a version in the file name, and a save deletes the older versions' files. `ShowsTodaySnapshot`
   does it by a `version` field that, when it differs, reads as nil.
6. A cache MUST be recoverable: a read that fails MUST end in a download or a new geocode, never an
   error shown for the cache. `AtlasCache` also drops an entry past its expiry when it loads.
7. A cache write MUST be atomic (`writeJSON` and the snapshot write both use `.atomic`), and a failed
   save MUST be logged and MUST NOT stop what the person was doing (`AtlasCache.add`).
8. Nothing about where the person is MUST be saved. Location, authorization and the current city are
   not stored ([RFC 008](008-nearby-location-filter.md)); only the filter, its mode and a city name the person typed are, per scene.
9. The widget and the app MUST share only the snapshot and the app group's name ([RFC 007](007-shows-today-widget.md)).
10. The archive (`Music`) MUST NOT be saved, only the `Bracket` made from it ([RFC 006](006-precomputed-music-data.md)).
11. Saved navigation MUST be pruned of pages the archive doesn't have, whenever the archive loads
    ([RFC 004](004-archive-path-category-navigation.md)).

## Not yet

- **`music.last.modified` and the `Bracket` can disagree.** The date is in the defaults and the
  `Bracket` is in Caches. A purged cache with a kept date is a cache failure, so it downloads;
  neither is checked against the other beyond that. See [#1728](https://github.com/bolsinga/site/issues/1728).
- **No version on the `Atlas` file, the Venue Places caches or scene state.** A change to
  `AtlasCache.Value` has to stay decodable (`source` is optional for this reason), and an
  `ArchiveNavigation.State` that stops decoding drops the whole scene state, not one field. See [#1726](https://github.com/bolsinga/site/issues/1726).
- **The key `nearby.distance` is a string literal in four places**, with its default beside each. See [#1725](https://github.com/bolsinga/site/issues/1725).

## Open questions

- Is the Atlas file replaced whole after an undecodable read? `AtlasCache` starts empty, and the next
  `add` saves only what it holds, so the old file is overwritten; this may be intended. See [#1726](https://github.com/bolsinga/site/issues/1726).
- `PickStore` has `removeAll()` for starting over after a read error; whether a user path reaches it
  was not checked. See [#1729](https://github.com/bolsinga/site/issues/1729).

## Rationale

- **Scene versus app.** Windows are independent, so what the person is looking at is per scene. A
  preference is the same everywhere, so it is per app.
- **Caches for what can be asked again.** The system may purge it, and every file there has a path
  back to the same data: a download, a geocode, a check.
- **Versions in the name or the field.** An old file that decodes is the worst case, since it shows
  wrong numbers with no error. A version turns it into a miss.
- **A stamp in the index itself.** The index is the one place that knows what it holds, so the stamp
  lives with it instead of in a file that could disagree.
