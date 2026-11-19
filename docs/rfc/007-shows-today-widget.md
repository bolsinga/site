# RFC 007: The Shows Today widget and its snapshot

Status: Accepted · Updated: 2026-11-19 · Code: `SiteWidgets`, `Shared/Sources/Shared/Widget`,
`Sources/Site/Music/SiteModel+Widget.swift`, `Sources/Site/Music/SiteModel.swift`

## Summary

The Shows Today widget lists the shows that happened on today's date in any year. It runs in its
own process, which has no network access to the archive and can't afford to load or derive it. So
the app publishes a **snapshot**, one file with every day's shows, into the app group's
container, and the widget only reads that file. This RFC is the snapshot, how it is published and
read, how the timeline follows the calendar, and how the widget links back. How the app itself
counts and shows a day is in the Today RFC.

## The snapshot

`ShowsTodaySnapshot` is `Codable`, and written as JSON with sorted keys and ISO 8601 dates.

| Field | Is |
|---|---|
| `version` | `currentVersion`, 2 |
| `generated` | the archive's modified date (`Vault.timestamp`), not when the file was written |
| `days` | `[dayOfLeapYear: [ShowDigest]]` for 1...366; a day with no shows is absent |

It is built from `Vault.concerts(on:)`, the lookup the app's Today screen uses, so the widget and
the app agree on what a day holds. The file is `Library/Application Support/shows-today.json` in
the container of the app group `group.gdb.SiteApp`, which the app and the widget extension both
declare in their entitlements.

### Rules

1. The widget MUST NOT load the archive, reach the network, or compute rankings. It reads the
   snapshot, and the snapshot holds everything it shows. What each `ShowDigest` carries (first
   and most recent flags, venue, location) is decided when the snapshot is built, from the
   precomputed data in RFC 006.
2. `currentVersion` MUST be bumped when what is stored changes meaning or shape, which includes a
   change to `ShowDigest`. A snapshot with another version reads as no snapshot, so the widget
   waits for the app to write a new one, instead of misreading an old one.
3. The snapshot is the app's to write and the widget's to read. Only the snapshot crosses the
   process boundary; nothing else is shared but the app group's name.
4. `generated` MUST be the archive's modified date and not the time of the write, so the same
   archive always gives the same bytes (rule 7).

## Publishing

`SiteModel.publishWidgetSnapshot` runs after each load that runs its asynchronous tasks (not a
preview), on iOS and macOS only; tvOS has no widget.

5. Building scales with the archive, so it MUST run off the main actor, at utility priority.
6. One publish runs at a time. Starting one cancels the one before, and a cancelled publish MUST
   NOT write, so an older snapshot can't land after a newer one.
7. A write MUST compare its bytes with the file's, and write only when they differ, atomically.
   Sorted keys make an unchanged archive produce identical bytes.
8. Timelines MUST be reloaded (`WidgetCenter.reloadTimelines`) only when the bytes changed. A
   launch with an unchanged archive wakes nothing.

The widget is therefore as current as the app's last load. An archive published to the website
doesn't reach the widget until the app has opened and downloaded it (RFC 005).

## The timeline

`ShowsTodayProvider` is an `AppIntentTimelineProvider`. Its configuration, `ShowsTodayOrder`,
chooses which of the day's shows is featured: oldest, newest, or random.

9. A timeline MUST hold an entry for the start of today and each of the next two local midnights,
   each built for its own day of the leap year. It reloads after the midnight following the last
   entry, so the widget is correct at midnight without the app running.
10. Each entry is one of three states: `shows` (a featured show and the others, in display
    order), `noShows`, or `needsAppLaunch` when there is no readable snapshot.
11. Random order is chosen when the timeline is built, so each day's featured show is fixed for
    that day and doesn't change when the widget is redrawn.
12. An entry's relevance is the day's show count over the busiest day's, so the system favors a
    busy day in a Smart Stack or StandBy for the rest of that day. A day with none scores 0.

## Links

The widget's URL is the Today category's URL, and a row's is that show's page. They are built
from `URL.archiveRoot` and the `ArchiveCategory` and `ArchivePath` URL forms (RFC 004), because
the widget has no `Vault` to ask. A row whose URL can't be built falls through to the widget's.
How the app handles the link is RFC 003.

## Appearance

The widget offers the system families (small, medium, large, and extra large on iPad and Mac),
and on iOS the Lock Screen families (rectangular, inline, circular).

13. Views that the app also uses live in `Shared` and take their settings from the environment.
    The widget MUST NOT depend on the app's models.
14. The new and last-seen markers are colored dots, which mean something only in color. They are
    shown only for the full-color rendering mode, and omitted in tinted and vibrant renderings.
15. Text MUST truncate or shrink, not grow, since a widget can't. A list shows as many rows as
    fit, and "+N more" counts the rest.

## Rationale

- **A file, not the archive.** A widget is a separate, short-lived process with a small budget.
  Reading a file decodes only what it shows, where loading the archive would repeat what the app
  already did.
- **All 366 days.** The widget moves to a new day at midnight with nothing running. A snapshot of
  just today would be wrong the next morning until the app was opened.
- **Write only on change.** Every reload spends the widget's refresh budget. Comparing bytes
  makes a launch that changed nothing cost nothing.
- **A version, not a migration.** A snapshot is rebuilt from the archive in a moment, so an old
  one is dropped and the widget says what to do.

## Platform notes

- A rebuilt widget on macOS keeps running the old code until `killall SiteWidgetsExtension`.
- Widgets are `#if !os(tvOS)` wherever the app touches them.
