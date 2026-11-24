# RFC 015: Continuous integration and release

Status: Accepted · Updated: 2026-11-23 · Code: `.github/workflows/main.yml`,
`.github/workflows/release.yml`, `.github/actions/setup-xcode/action.yml`, `.github/actions/check-format/action.yml`, `.github/actions/check-boundaries`, `.github/dependabot.yml`, `Config.xcconfig`,
`SiteApp.xcodeproj` (scheme `SiteApp`, build settings), `Sources/App/SiteApp.entitlements`,
`SiteWidgets/SiteWidgetsExtension.entitlements`

## Summary

Two GitHub Actions workflows build the app, and one of them also runs the tests. Neither signs,
archives, uploads or publishes anything. This RFC is what each workflow runs and when, how the
project is versioned and signed, and what a change has to pass. It records what the files do, and
how a release is made by hand today, not what a release process should be.

## Workflows

| | `push-and-prs-on-main` (`main.yml`) | `release-builds` (`release.yml`) |
|---|---|---|
| Trigger | a push to `main`, or a pull request into `main` | a GitHub release is `published` |
| Runner | `xcode-27` | `xcode-27` |
| Steps | identical | identical |

The steps are identical, so a release gets the same checks a pull request does, on the release's
commit, and nothing more. `release.yml` also lists `branches: [ main ]` under `release`. GitHub
documents `branches` filters for push and pull request events, so under `release` it has no
documented effect, and a release is built from the tag it was published on.

### Jobs

Each workflow has three jobs. `build` is the matrix below. `format` is one step, the local action
`.github/actions/check-format`, so both workflows share it. It runs the setup action, then
`xcrun swift-format format --in-place --recursive Sources Shared/Sources Shared/Tests Shared/Package.swift SiteKit/Sources SiteKit/Tests SiteKit/Package.swift Tests SiteWidgets`, and
fails if that changes any file (`git diff --exit-code`), printing the change and the command that
fixes it. The directories are its `paths` input. `boundaries` is one step too, the local action
`.github/actions/check-boundaries`, which runs `check.sh` (it takes a repository root, so it can be
run by hand). It fails if a file of `SiteKit/Sources/SiteCore` imports `SwiftUI`, `UIKit`, `AppKit`,
`WidgetKit` or `AppIntents`; if it uses `.shared`, `UserDefaults`, `.standard`, `Bundle.main` or
`ProcessInfo.processInfo`; or if it uses `FileManager.default` or `NotificationCenter.default`
anywhere but as the default value of a parameter.

### Matrix

One job per destination, with `fail-fast: false`, so one platform failing doesn't cancel the others.

| Destination | Runs |
|---|---|
| `platform=macOS` | `xcodebuild test` of scheme `SiteApp`, `swift test` of the `Shared` and `SiteKit` packages, then a build of scheme `SiteApp` |
| `generic/platform=iOS Simulator` | a build of scheme `SiteApp` |
| `generic/platform=tvOS Simulator` | a build of scheme `SiteApp` |

Before building, each job checks out with `actions/checkout@v7`, then runs the local action
`.github/actions/setup-xcode`. It prints `sw_vers` and the installed Xcodes, selects the newest
`/Applications/Xcode_27.*.app` with `xcode-select`, accepts the license, runs first launch,
checks that the version is at least its `minimum-version` input (27.2), and prints the SDKs and
the scheme's destinations. All builds pass `-skipPackagePluginValidation`.
The macOS test run passes `CODE_SIGNING_ALLOWED=NO`; the build steps don't.

### Changing the Xcode version

The floor is the `default` of `minimum-version` in `.github/actions/setup-xcode/action.yml`, and
the workflows don't pass it.

- **A newer point release (27.3):** nothing changes. The newest installed `Xcode_27.*.app` is used.
- **A higher floor in the same major version:** raise the default, such as to `'27.3'`.
- **A new major version (28):** raise the default to `'28.0'` or higher, because the major version
  of the default decides which `Xcode_*` apps are considered, and change the runner label in both
  workflows. Rule 3 and the table above change with them.

### How a release is made today

A release is made at the desk. Nothing about it is automated:

1. The versions are bumped at the desk: `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`, by
   hand ([#1785](https://github.com/bolsinga/site/issues/1785) would automate it).
2. The signed app is built at the desk, with the team id in the git-ignored
   `DevelopmentTeam.xcconfig`, and distributed from there ([#1786](https://github.com/bolsinga/site/issues/1786)
   would build and sign it in CI).
3. Publishing a GitHub release runs `release.yml`, which repeats the checks of `main.yml` and
   produces no artifact.

The team id is kept out of the repository by `DevelopmentTeam.xcconfig` (see Versions and
signing). No workflow reads a secret.

### What CI does not do

No step runs a UI test, a physical-device build, an archive, a notarization or an
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
configuration, which is Debug for a build and a test. The test action has its own environment, not
the run action's, and sets `SITE_QUIET_HOST=1`, which makes the app that hosts the tests start none
of its own work ([RFC 016](016-testing.md)).

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
or build phase sets or increments them. `Tests` keeps `1.0` and `1`, as its bundle isn't
distributed. `Config.xcconfig` includes `DevelopmentTeam.xcconfig` with
`#include?`, so the file is optional. It is git-ignored, so CI builds without a team, and a local
build with that file signs with the developer's team.

## Rules

1. A change MUST build with scheme `SiteApp` for `platform=macOS`, `generic/platform=iOS
   Simulator` and `generic/platform=tvOS Simulator`. Each is its own job, and a failed job fails
   the pull request.
2. The `Tests` target and the tests of the `Shared` and `SiteKit` packages MUST pass on macOS. It is the only platform
   the tests run on in CI.
3. The workflows MUST build with Xcode 27.2 or newer on a runner labeled `xcode-27`, and fail
   when the newest installed Xcode of that major version is older than 27.2. The minimum is the
   `minimum-version` input of `.github/actions/setup-xcode`, in one place. A change to the runner
   label is a change to both workflow files, and they MUST stay the same.
4. `main.yml` and `release.yml` MUST keep running the same steps, so a release is never built
   with different checks than the commit it was merged with.
5. The app, the widget and the app group id MUST match across `project.pbxproj` and both
   entitlements files. The widget reads the app's snapshot through that group ([RFC 007](007-shows-today-widget.md)).
6. `SiteApp` and `SiteWidgetsExtension` MUST share `MARKETING_VERSION` and
   `CURRENT_PROJECT_VERSION` in every configuration. A version change edits all four.
7. A change MUST NOT put a team id, certificate or token in a tracked file. The team id belongs in
   the git-ignored `DevelopmentTeam.xcconfig`.
8. Code MUST be `swift-format` clean (default configuration): the `format` job fails a change
   that `swift-format format` would alter, and a release is checked the same way. `CLAUDE.md`
   still says to format before pushing, so the job doesn't fail a change that could have been
   formatted first.
9. Code new on a platform MUST be guarded for the platforms that lack it, such as
   `#if !os(tvOS)`, since the tvOS build is a CI job.
10. Dependabot MAY open pull requests for `github-actions`, weekly and grouped into one. They are
    held to rules 1 and 2 like any other change.
11. `SiteCore` MUST NOT import a UI or App Intents framework or reach global state. What it needs
    from the system comes in through a parameter, and the app supplies its own; the `boundaries`
    job enforces it ([RFC 016](016-testing.md)).

## Rationale

- **Build all three, test one.** The tvOS and iOS builds catch API gaps and unguarded code. The
  tests are about data and logic, and one platform covers them. The package tests were tried on
  the iOS and tvOS simulators and passed, but booting a simulator and building each package for it
  took 5 to 15 minutes against seconds of tests, so they stay on macOS.
- **Simulators and generic destinations.** They need no device or signing, so any runner can
  build them.
- **Signing off for tests only.** The test run must not need a team, which CI doesn't have.
- **Release repeats the checks.** A published release is built the way a pull request is, and the
  workflow can fail visibly on that commit.
- **Newest of a major version, with a floor.** A runner image that has a later 27.x but not the
  exact one still builds, and a runner whose Xcode is too old fails with the reason, not with a
  compile error. The floor is in one action, so both workflows share it.
- **Format, not lint.** The check formats and then looks for changes, so it asks whether the code
  is what the formatter makes. `swift-format lint` also reports rules the formatter doesn't fix
  (such as `ReplaceForEachWithForLoop` and `AlwaysUseLowerCamelCase`), which the code base
  doesn't follow.
- **Boundaries by search.** The model is in a package so it can be tested without the app, which
  only holds while it takes the system's services as parameters. A search of its sources is
  enough to notice a framework import or a singleton, and it runs in seconds, without a build.
- **Hand-edited versions.** The numbers are in one file per target and change in a commit, made at
  the desk where the release is built.

## Open questions

- **Automated version bump.** The versions are bumped by hand. See [#1785](https://github.com/bolsinga/site/issues/1785).
- **Signed builds from CI.** Signed builds are made locally, and CI has no secrets. See [#1786](https://github.com/bolsinga/site/issues/1786).
- **Test coverage.** The tests don't run on iOS or tvOS in CI, and no test plan is used, as one test target in one environment gains nothing from it.
- **Lint.** `swift-format lint` with the default configuration reports 28 errors on the code
  base as it is, in rules the formatter doesn't fix. Whether CI should run it, with those fixed or
  a configuration that turns them off, is open. See [#1742](https://github.com/bolsinga/site/issues/1742).
