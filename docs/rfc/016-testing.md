# RFC 016: Testing

Status: Accepted · Updated: 2026-11-19 · Code: `Tests/` (`SiteTests`, `MusicDataTests`,
`UtilitiesTests`), `Sources/Site/Music/UI` (`VaultPreviewModifier`, `NearbyPreviewModifer`),
`.github/workflows/main.yml`

## Summary

The tests are unit tests of the data model, the navigation state and the pure policies, written
with the Testing framework. They run in one target, `Tests`, through the `SiteApp` scheme. There
are no UI tests. SwiftUI previews are the way views are checked, and they have their own fixtures.
This RFC says how the tests are laid out, how a `Vault` is made for them, how time, location and
files are made deterministic, and what has no tests.

## Targets

| Folder | Imports | Tests |
|---|---|---|
| `Tests/MusicDataTests` | `Shared`, some `SiteApp` | `ArchivePath`, `ArchiveCategory`, `Annum`, `PartialDate`, `Decade`, ranking, `Vault` statistics, Shows Today snapshot and stats |
| `Tests/UtilitiesTests` | `Shared`, some `SiteApp` | `DayOfLeapYear`, Shows Today timeline, library sorting, token comparison |
| `Tests/SiteTests` | `Shared` and `SiteApp` | navigation, user activities, entity identifiers, location filter and city, venue places, atlas cache, search, paging |

The tests run as the one `Tests` target of `SiteApp.xcodeproj`, hosted by the app (`TEST_HOST`).
`Shared` has no test target of its own.

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

There is no sample data file and no fixture in `Tests/`. A test builds what it needs in code.

- A `Vault` is made from a small `Music(albums:artists:relations:shows:songs:venues:)` value,
  wrapped as `Vault(lookup: Lookup(bracket: Bracket(music:timestamp:)), rootURL:)`. A test that
  only needs the shape passes empty arrays and `https://www.example.com/` as the root.
- A test that needs a `VaultModel` makes it from such a `Vault` (see `CurrentCityTests`).
- Tests MUST NOT fetch from the network. The live JSON is only for previews.

## Previews

Previews are the fixture for views, not the tests. `PreviewTrait` extensions in
`Sources/Site/Music/UI` give them their environment:

| Trait | Gives |
|---|---|
| `.vaultModel` | a `VaultModel` loaded with `SiteModel.load(.preview)` from `https://www.bolsinga.com/json/shows.json` |
| `.vaultModelWithError` | the same model with its `error` set to `VaultError.illegalURL` |
| `.nearbyModel` | a fresh `NearbyModel` |

`VaultModel` has `preview…` helpers (`previewShow`, `previewVenue`, `previewArtist`,
`previewAnnum`, `previewAllArtists`, `previewAllVenues`). They force-unwrap, so they are for
previews only, and no test uses these traits or helpers. `Reason.preview` does not start the
asynchronous tasks the other reasons start, and loads with no previous modified date.

## Determinism

1. Code that depends on the clock MUST take the time as a parameter, and a test MUST pass it.
   `ReverseGeocodePolicy.shouldGeocode(last:location:now:)` and the Shows Today timeline are
   tested with fixed `Date` values; no test reads `Date.now` for an expectation.
2. Code that depends on the geocoder MUST be reached through a protocol the test can replace.
   `CityResolver` is stubbed with `StubResolver` and `DelayedResolver`, the latter using
   `Task.sleep` to order in-flight lookups. RFC 008 describes the policy and RFC 002 the geocoding.
3. Locations in tests are `CLLocation` constants with their distances in a comment.
4. `ArchiveNavigation` tests MUST be built with `useDispatchMainWorkaround: false`, so the state
   changes are synchronous. The test file adds convenience initializers that do so. RFC 004
   describes the state.
5. A test that writes a file MUST use a unique name, either under `URL.temporaryDirectory` or an
   `AtlasCache` file named with a `UUID`, and MUST remove it with `defer`.
6. Dates are made with `DateComponents(calendar:…)`. Which calendar is used is an open question.

## Running

- `xcodebuild test` runs the `SiteApp` scheme on `platform=macOS`. The iOS and tvOS simulator
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
- **Pure policies.** Taking `now` and a resolver as arguments tests the rules of RFC 008
  without a clock, a network or a location permission prompt.
- **Previews for views.** The previews load the real archive, so they show real data, and are not
  a substitute for deterministic tests.
- **One target.** A single `Tests` target gives one scheme action for CI.

## Open questions

- **Calendar and time zone.** Tests build dates with `Calendar.autoupdatingCurrent`, so they
  assume the machine's calendar and time zone. A fixed Gregorian calendar and time zone would
  make them the same everywhere.
- **Previews need the network.** `.vaultModel` fetches the live JSON, so a preview fails offline.
  A bundled sample would not.
- **Simulator tests.** CI builds for iOS and tvOS but does not test there.
- **Test plan.** No `.xctestplan` was found; whether one is wanted is not decided.
