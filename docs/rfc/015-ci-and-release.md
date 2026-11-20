# RFC 015: Continuous integration and release

Status: Accepted · Updated: 2026-11-19 · Code: `.github/workflows/main.yml`,
`.github/workflows/release.yml`, `.github/dependabot.yml`, `Config.xcconfig`,
`SiteApp.xcodeproj` (scheme `SiteApp`, build settings), `Sources/App/SiteApp.entitlements`,
`SiteWidgets/SiteWidgetsExtension.entitlements`

## Summary

Two GitHub Actions workflows build the app, and one of them also runs the tests. Neither signs,
archives, uploads or publishes anything. This RFC is what each workflow runs and when, how the
project is versioned and signed, and what a change has to pass. It records what the files do, not
what a release process should be.

## Workflows

| | `push-and-prs-on-main` (`main.yml`) | `release-builds` (`release.yml`) |
|---|---|---|
| Trigger | a push to `main`, or a pull request into `main` | a GitHub release is `published` |
| Runner | `xcode-27` | `xcode-27` |
| Steps | identical | identical |

The steps are identical, so a release gets the same checks a pull request does, on the release's
commit, and nothing more. `release.yml` also lists `branches: [ main ]` under `release`.

### Matrix

One job per destination, with `fail-fast: false`, so one platform failing doesn't cancel the others.

| Destination | Runs |
|---|---|
| `platform=macOS` | `xcodebuild test` of scheme `SiteApp`, then a build of the same scheme |
| `generic/platform=iOS Simulator` | a build of scheme `SiteApp` |
| `generic/platform=tvOS Simulator` | a build of scheme `SiteApp` |

Before building, each job checks out with `actions/checkout@v7`, selects `/Applications/Xcode_27.2.app`
with `xcode-select`, accepts the license, runs first launch, and prints `sw_vers`, the installed
Xcodes, the SDKs and the scheme's destinations. All builds pass `-skipPackagePluginValidation`.
The macOS test run passes `CODE_SIGNING_ALLOWED=NO`; the build steps don't.

### What CI does not do

No step runs `swift-format`, a UI test, a physical-device build, an archive, a notarization or an
upload. No step reads a repository secret or an input; the only credential-shaped setting is
`DEVELOPMENT_TEAM`, which comes from a local file (see Versions and signing).

## Scheme and targets

| Target | Product | Platforms |
|---|---|---|
| `SiteApp` | application | macOS, iOS, tvOS (`appletvos`, `iphoneos`, simulators, `macosx`) |
| `SiteWidgetsExtension` | app extension | iOS and macOS only, no tvOS |
| `Tests` | unit-test bundle | run by the scheme's `Tests.xctest` testable |

The shared scheme `SiteApp` builds `SiteApp.app` for testing and runs the `Tests` testable in
Debug. Its archive action uses Release. `xcodebuild` builds with the scheme's default
configuration, which is Debug for a build and a test.

## Versions and signing

| Setting | Value | Where |
|---|---|---|
| `MARKETING_VERSION` | `2.0.1` | `SiteApp` and `SiteWidgetsExtension`, Debug and Release |
| `CURRENT_PROJECT_VERSION` | `23` | the same four configurations |
| `MARKETING_VERSION`, `CURRENT_PROJECT_VERSION` | `1.0`, `1` | `Tests` |
| Deployment targets | `27.0` for macOS, iOS and tvOS | project level |
| Bundle ids | `gdb.SiteApp`, `gdb.SiteApp.SiteWidgets`, `gdb.Tests` | per target |
| App group | `group.gdb.SiteApp` | app and widget entitlements |
| Associated domain | `applinks:www.bolsinga.com` | app entitlements only |
| `DEVELOPMENT_TEAM` | `$(inherited)`, from `Config.xcconfig` | project |

Versions are literal numbers in `project.pbxproj`, edited by hand in a commit. No workflow, script
or build phase sets or increments them. `Config.xcconfig` includes `DevelopmentTeam.xcconfig` with
`#include?`, so the file is optional. It is git-ignored, so CI builds without a team, and a local
build with that file signs with the developer's team.

## Rules

1. A change MUST build with scheme `SiteApp` for `platform=macOS`, `generic/platform=iOS
   Simulator` and `generic/platform=tvOS Simulator`. Each is its own job, and a failed job fails
   the pull request.
2. The `Tests` target MUST pass on macOS. It is the only platform the tests run on in CI.
3. The workflows MUST build with Xcode 27.2 on a runner labeled `xcode-27`. A change to the Xcode
   version or the runner label is a change to both workflow files, and they MUST stay the same.
4. `main.yml` and `release.yml` MUST keep running the same steps, so a release is never built
   with different checks than the commit it was merged with.
5. The app, the widget and the app group id MUST match across `project.pbxproj` and both
   entitlements files. The widget reads the app's snapshot through that group ([RFC 007](007-shows-today-widget.md)).
6. `SiteApp` and `SiteWidgetsExtension` MUST share `MARKETING_VERSION` and
   `CURRENT_PROJECT_VERSION` in every configuration. A version change edits all four.
7. A change MUST NOT put a team id, certificate or token in a tracked file. The team id belongs in
   the git-ignored `DevelopmentTeam.xcconfig`.
8. Code MUST be `swift-format` clean (default configuration) before each commit is pushed, per
   `CLAUDE.md`. CI doesn't check this, so the author does.
9. Code new on a platform MUST be guarded for the platforms that lack it, such as
   `#if !os(tvOS)`, since the tvOS build is a CI job.
10. Dependabot MAY open pull requests for `github-actions`, weekly and grouped into one. They are
    held to rules 1 and 2 like any other change.

## Rationale

- **Build all three, test one.** The tvOS and iOS builds catch API gaps and unguarded code. The
  tests are about data and logic, and one platform covers them.
- **Simulators and generic destinations.** They need no device or signing, so any runner can
  build them.
- **Signing off for tests only.** The test run must not need a team, which CI doesn't have.
- **Release repeats the checks.** A published release is built the way a pull request is, and the
  workflow can fail visibly on that commit.
- **Hand-edited versions.** The numbers are in one file per target and change in a reviewed commit.

## Open questions

- **What a release ships.** `release-builds` produces no artifact, and no file says how the app
  reaches users or the App Store, or what signing or `ExportOptions` it uses.
- **Release trigger.** Whether the `branches: [ main ]` under `release` limits releases to `main`
  is not stated anywhere in the repo.
- **Who bumps versions.** Nothing says when `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`
  change, or why `Tests` stays at `1.0` and `1`.
- **Secrets.** No workflow names a secret or input. How a release is signed is outside the files.
- **Formatting.** The format check is manual. Whether CI should run `swift-format lint` is open.
- **Test coverage.** The tests don't run on iOS or tvOS in CI, and no test plan is used.
- **Xcode pin.** `Xcode_27.2.app` is hard-coded, so a runner image without it fails.
