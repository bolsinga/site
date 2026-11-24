# RFC 016: Testing

Status: Accepted · Updated: 2026-11-23 · Code: `Tests/SiteTests`, `Sources/App/LaunchMode.swift`, `SiteKit/Tests/SiteCoreTests`, `SiteKit/Sources/SiteUI` (`VaultPreviewModifier`, `NearbyPreviewModifer`), `SiteKit/Sources/SiteUI/sample-shows.json`,
`.github/workflows/main.yml`

## Summary

The tests are unit tests of the data model, the navigation state and the pure policies, written
with the Testing framework. They run in three places: the app-hosted `Tests` target, through the
`SiteApp` scheme, and the `SiteCoreTests` and `SiteUITests` of the `SiteKit` package, which need no host. There
are no UI tests. SwiftUI previews are the way views are checked, and they have their own fixtures.
This RFC says how the tests are laid out, how a `Vault` is made for them, how time, location and
files are made deterministic, and what has no tests.

## Targets

| Folder | Imports | Tests |
|---|---|---|
| `SiteKit/Tests/SiteUITests` | `SiteUI`, `SiteCore`, `SiteTestSupport` | navigation state, the missing path rules, tab state, paging, map fit, the sample archive, persisted state versions, `Annum` neighbours |
| `SiteKit/Tests/SiteCoreTests` | `SiteCore`, `SiteTestSupport` | `ArchivePath`, `ArchiveCategory`, `Annum` formats, `PartialDate`, `Decade`, ranking, calendar and day of the leap year, library sorting, token and ID comparison, `Vault` statistics, first and most recent sets, `Bracket` loading and cache, Shows Today snapshot, stats and timeline, `VaultModel` and its location source, location filter and city, `SiteModel` loading, `VaultLoader`, atlas cache, category sort activities, search matching, months, weekdays, rank distribution, library sections, digest comparison, the widget snapshot publish |
| `Tests/SiteTests` | `SiteApp`, `SiteCore` | entity identifiers and catalog, concert search, user activities of entities, venue places, the cache age of places |

`SiteCoreTests` and `SiteUITests` are test targets of the `SiteKit` package, run with
`swift test --package-path SiteKit`. They have no host, so they start nothing from the app. The
rest run as the one `Tests` target of `SiteApp.xcodeproj`, hosted by the app (`TEST_HOST`). A test
that imports nothing from `SiteApp` belongs in a package target. `SiteTestSupport` is a target of
`SiteKit` that holds `InMemoryCache`, for the package tests. `Tests` compiles that one file itself,
and doesn't link the target, so there is no second copy of `SiteCore` in the test bundle. `Tests`
and the packages turn on `MemberImportVisibility`, as the app does, so a test file imports a module
only when it uses something that module declares; an
import it doesn't need is how a test that could run without the app is spotted.

## Framework

1. Tests MUST use the Testing framework: `import Testing`, `@Test`, `#expect` and `#require`.
   No file uses XCTest.
2. A suite is a `struct` named for what it covers, in `<Subject>Tests.swift`. `@Suite` is not
   used. A suite that touches main-actor types is marked `@MainActor`.
3. Tests import their subjects with `@testable import SiteCore` or `@testable import SiteApp`.
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
`SiteKit/Sources/SiteUI` give them their environment:

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
they are there. A preview that needs another id adds its show to the sample. The file is a resource of `SiteUI`, read with `#bundle`, so a
preview of a view in the package finds it, and it is in a release build too, at 16 KB.

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
7. Code that needs the system MUST take it through an initializer or a property a test can set,
   and the app's own is the default. `VaultModel` takes a `LocationSource` (where locations and the
   answer to the prompt come from), the clock as `now`, and the `NotificationCenter` that reports a
   day change. `AtlasCache` takes `now`. `SiteModel` has the widget write and reload, the Spotlight
   index and how a `VaultModel` is made as properties, which the app sets, and its `VaultLoader` takes
   the load. The `boundaries` CI job fails a `SiteCore` source that imports a UI framework or reaches
   a singleton ([RFC 015](015-ci-and-release.md)). A
   test of work in flight orders it with a `Gate` and not with `Task.sleep`. `EntityVault.provider`
   is the one global, as the system asks an entity for some properties outside an intent, and no
   test reads it.

## Running

- `xcodebuild test` runs the `SiteApp` scheme on `platform=macOS`, and `swift test --package-path
  SiteKit` runs the package tests. The iOS and tvOS simulator
  destinations only build; no test runs there, as a simulator costs minutes in CI for seconds of
  tests ([RFC 015](015-ci-and-release.md)). This matches CLAUDE.md.
- Nothing runs on a physical device. Locally, tests run on My Mac or a simulator.
- The app that hosts `Tests` is launched in the quiet mode. The scheme's test action sets
  `SITE_QUIET_HOST=1` in its own environment, and `LaunchMode` reads it. In that mode `SiteAppApp`
  shows an empty scene and skips its startup: the loader and its registration with App Intents, the
  shortcut parameters, and so the archive load, the widget publish, the Spotlight index, the
  day-change monitoring and the batch geocode. No test depends on any of them. The mode is a setting
  the scheme gives, and the app doesn't look for a test run; `LaunchModeTests` fails if the scheme
  loses the setting.

## Not yet covered

- Views: how `SiteKit/Sources/SiteUI` and `SiteKit/Sources/SiteUI` look and lay out has no tests; previews only.
- Widgets: the Shows Today snapshot, stats and timeline have tests, `SiteWidgets` does not.
- Intents: entity identifiers and `ConcertSearch` have tests; the queries, `Open…` intents and
  `SiteShortcuts` have none that this RFC found.
- `LocationManager` itself, the CoreLocation calls under `LocationSource`.
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
- **A hostless target for `SiteCore`.** Its tests run without launching the app, so they don't
  start the app's own work or depend on the website being reachable.
