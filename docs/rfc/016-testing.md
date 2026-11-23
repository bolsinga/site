# RFC 016: Testing

Status: Accepted · Updated: 2026-11-22 · Code: `Tests/` (`SiteTests`, `MusicDataTests`,
`UtilitiesTests`), `Shared/Tests/SharedTests`, `Sources/Site/Music/UI` (`VaultPreviewModifier`, `NearbyPreviewModifer`), `Sources/App/Preview Content/sample-shows.json`,
`.github/workflows/main.yml`

## Summary

The tests are unit tests of the data model, the navigation state and the pure policies, written
with the Testing framework. They run in two places: the app-hosted `Tests` target, through the
`SiteApp` scheme, and the `Shared` package's own `SharedTests`, which need no host. There
are no UI tests. SwiftUI previews are the way views are checked, and they have their own fixtures.
This RFC says how the tests are laid out, how a `Vault` is made for them, how time, location and
files are made deterministic, and what has no tests.

## Targets

| Folder | Imports | Tests |
|---|---|---|
| `Shared/Tests/SharedTests` | `Shared` | calendar and day of the leap year, `Vault` statistics, first and most recent sets, ID comparison, Shows Today snapshot, stats and timeline |
| `Tests/MusicDataTests` | `Shared`, some `SiteApp` | `ArchivePath`, `ArchiveCategory`, `Annum`, `PartialDate`, `Decade`, ranking, `Bracket` loading and cache |
| `Tests/UtilitiesTests` | `Shared`, some `SiteApp` | `DayOfLeapYear`, library sorting, token comparison |
| `Tests/SiteTests` | `Shared` and `SiteApp` | navigation, user activities, entity identifiers, location filter and city, venue places, atlas cache, search, paging |

`SharedTests` is a test target of the `Shared` package, run with `swift test --package-path Shared`.
It has no host, so it starts nothing from the app. The rest run as the one `Tests` target of
`SiteApp.xcodeproj`, hosted by the app (`TEST_HOST`). A test that imports only `Shared` belongs in
`SharedTests`. The `Bracket` loading and cache tests stay in `Tests` for now, as they share
`InMemoryCache` with tests of the app's atlas and venue code.

## Framework

1. Tests MUST use the Testing framework: `import Testing`, `@Test`, `#expect` and `#require`.
   No file uses XCTest.
2. A suite is a `struct` named for what it covers, in `<Subject>Tests.swift`. `@Suite` is not
   used. A suite that touches main-actor types is marked `@MainActor`.
3. Tests import their subjects with `@testable import Shared` or `@testable import SiteApp`.
4. A test that runs one case over many inputs SHOULD use `@Test(arguments:)`, with
   `ArchiveCategory.allCases` for each category. A display name is optional; the
   navigation tests give one, most tests don't.
5. A test that expects a failure MUST use `#expect(throws:)`.

## Making data

There is no data file and no fixture in `Tests/`. A test builds what it needs in code. The one
sample archive is `sample-shows.json`, for previews, and a test checks it ([Previews](#previews)).

- A `Vault` is made from a small `Music(albums:artists:relations:shows:songs:venues:)` value,
  wrapped as `Vault(lookup: Lookup(bracket: Bracket(music:timestamp:)), rootURL:)`. A test that
  only needs the shape passes empty arrays and `https://www.example.com/` as the root.
- A test that needs a `VaultModel` makes it from such a `Vault` (see `CurrentCityTests`).
- Tests MUST NOT fetch from the network. Previews don't either.

## Previews

Previews are the fixture for views, not the tests. `PreviewTrait` extensions in
`Sources/Site/Music/UI` give them their environment:

| Trait | Gives |
|---|---|
| `.vaultModel` | `VaultModel.sample()`: a `VaultModel` of `sample-shows.json`, made with `Vault(json:rootURL:)`, with no network |
| `.vaultModelWithError` | the same model with its `error` set to `VaultError.illegalURL` |
| `.nearbyModel` | a fresh `NearbyModel` |

`VaultModel` has `preview…` helpers (`previewShow`, `previewVenue`, `previewArtist`,
`previewAnnum`, `previewAllArtists`, `previewAllVenues`). They force-unwrap, so they are for
previews only. `sample-shows.json` is 20 shows of the real archive, with their artists, venues and one
relation, and keeps their ids. The previews look up some of them (`sh1`, `sh100`, `sh500`,
`sh899`, `ar692`, `v0`, `v103` and the years 2000 to 2002), and `SampleMusicTests` checks that
they are there. A preview that needs another id adds its show to the sample. The file is in `Preview Content`, a
development asset path, so it is not in a release build.

## Determinism

1. Code that depends on the clock MUST take the time as a parameter, and a test MUST pass it.
   `ReverseGeocodePolicy.shouldGeocode(last:location:now:)` and the Shows Today timeline are
   tested with fixed `Date` values; no test reads `Date.now` for an expectation.
2. Code that depends on the geocoder MUST be reached through a protocol the test can replace.
   `CityResolver` is stubbed with `StubResolver` and `DelayedResolver`, the latter using
   `Task.sleep` to order in-flight lookups. [RFC 008](008-nearby-location-filter.md) describes the policy and [RFC 002](002-mapkit-geocoding.md) the geocoding.
3. Locations in tests are `CLLocation` constants with their distances in a comment.
4. `ArchiveNavigation` tests MUST be built with `useDispatchMainWorkaround: false`, so the state
   changes are synchronous. The test file adds convenience initializers that do so. [RFC 004](004-archive-path-category-navigation.md)
   describes the state.
5. A test of a cache MUST NOT use the disk. `Bracket`, `AtlasCache` and the `Dictionary` JSON caches
   take a `CacheCodable` (`FileManager` is the real one), and tests give them `InMemoryCache`,
   which keeps files in memory and records what was saved, read and removed. A test that has to
   write a real file MUST use a unique name under `URL.temporaryDirectory` and remove it with
   `defer`.
6. Dates are made with `DateComponents(calendar: .archive, …)`, which is Gregorian, so no test
   depends on the machine's calendar. A test of code that takes a calendar (`ShowsTodayTimeline`,
   `dayOfLeapYear(in:)`) MUST pass a Gregorian one with a fixed time zone.

## Running

- `xcodebuild test` runs the `SiteApp` scheme on `platform=macOS`, and `swift test --package-path
  Shared` runs `SharedTests`. The iOS and tvOS simulator
  destinations only build; no test runs there. This matches CLAUDE.md.
- Nothing runs on a physical device. Locally, tests run on My Mac or a simulator.

## Not yet covered

- Views: `Sources/Site/Music/UI` and `Shared/Sources/Shared/UI` have no tests; previews only.
- Widgets: the Shows Today snapshot, stats and timeline have tests, `SiteWidgets` does not.
- Intents: entity identifiers and `ConcertSearch` have tests; the queries, `Open…` intents and
  `SiteShortcuts` have none that this RFC found.
- `SiteModel` loading, refresh ordering and `LocationManager`.
- `ClusterMap`, and the MapKit and geocoding calls themselves (the atlas cache and the batch
  logic are tested through stand-ins).
- `site_tool`.

## Rationale

- **Plain values, no fixtures.** A small `Music` in the test shows the data a case depends on.
  A shared fixture file would hide it and need updating when the model changes.
- **Pure policies.** Taking `now` and a resolver as arguments tests the rules of [RFC 008](008-nearby-location-filter.md)
  without a clock, a network or a location permission prompt.
- **Previews for views.** The previews show real shows from a small sample, so they work offline,
  and are not a substitute for deterministic tests.
- **A hostless target for `Shared`.** Its tests run without launching the app, so they don't
  start the app's own work or depend on the website being reachable.

## Open questions

- **Simulator tests.** CI builds for iOS and tvOS but does not test there. See [#1743](https://github.com/bolsinga/site/issues/1743).
- **Test plan.** No `.xctestplan` was found; whether one is wanted is not decided. See [#1743](https://github.com/bolsinga/site/issues/1743).
