# RFC 010: Today and the day of the leap year

Status: Accepted · Updated: 2026-11-23 · Code: `SiteKit/Sources/SiteCore/Utilities/Date+DayOfLeapYear.swift`,
`SiteKit/Sources/SiteCore/DayOfLeapYear+Title.swift`, `SiteKit/Sources/SiteCore/NoShowsMessage.swift`,
`SiteKit/Sources/SiteCore/VaultModel.swift`, `SiteKit/Sources/SiteUI` (`ArchiveTabView`, `ArchiveTabState`,
`TabSelection`, `ArchiveStateView`, `DayBrowser`, `DayList`, `DaySummary`)

## Summary

The Today tab shows the shows that happened on this calendar date, in any year. A date is named
by a number, the **day of the leap year**, which is the same for a given month and day whatever
the year. This RFC is how that number is defined and used, how the app decides what today is and
keeps it right at midnight and after a resume, and how the Today screen pages from one day to the
next. The widget's use of it is [RFC 007](007-shows-today-widget.md).

## The day of the leap year

It is the day of the year counted as if the year had 366 days, so 1 is January 1st and 366 is
December 31st, and a given month and day always has the same number.

| Date | In a leap year | In another year |
|---|---|---|
| January 1 | 1 | 1 |
| February 28 | 59 | 59 |
| February 29 | 60 | doesn't exist |
| March 1 | 61 | 61 |
| December 31 | 366 | 366 |

### Rules

1. A date MUST be turned into a day with `Date.dayOfLeapYear`, which adds one to the day of the
   year from March 1st on in a year that has 365 days. Code MUST NOT use the plain day of the year
   to compare dates across years, as it differs by one after February in a leap year.
   The archive's dates are Gregorian, so the day is found in `Calendar.archive`, which is
   Gregorian in the person's time zone, whatever calendar they use. `dayOfLeapYear(in:)` takes
   the calendar, for tests. A date of the archive is shown with `.archiveDateTime`, not `.dateTime`.
2. A day is moved with `nextDayOfLeapYear` and `previousDayOfLeapYear`, which wrap from 366 to 1
   and from 1 to 366. A number outside 1...366 has no next or previous (`-1`) and no date text.
3. The text of a day (`3/1`) is formatted for a leap year, 2024, so every day has one.
4. Only a show with a fully known date has a day. A show with a missing year, month or day is
   not in the day map, and doesn't appear on Today.
5. The day map in the precomputed archive ([RFC 006](006-precomputed-music-data.md)), the day's rank, the widget's snapshot
   ([RFC 007](007-shows-today-widget.md)) and the intents' "today" ([RFC 009](009-entities-siri-spotlight.md)) MUST all use this one definition, so every
   surface agrees about what a day holds.

In a year that is not a leap year, day 60 is never today, since February 28th is followed by
March 1st. February 29th's shows are reached by paging: they are tomorrow on February 28th and
yesterday on March 1st, and show as "Tomorrow: 2/29" and "Yesterday: 2/29".

## What today is

`VaultModel.todayDayOfLeapYear` is the app's idea of today. It starts as the day when the model is
made, and changes only when the calendar's day does.

6. It MUST be updated on `NSCalendarDayChanged`, and by `refreshToday()` when the scene becomes
   active and when a link or Handoff asks for Today. The notification can be missed while the
   app is suspended, so the second path is the one that catches a resume.
7. An update to the same day MUST do nothing, so observers don't reload for no change.
8. A view that needs to know whether a day is today MUST compare against the current date when
   it asks (`isToday`), and the widget MUST be told instead (`NoShowsMessage(isToday:)`), because
   a widget renders future entries early.

## The Today screen

On iOS and iPadOS, `DayBrowser` shows three pages, yesterday, today and tomorrow, in a paged
`TabView`, with one map behind them that follows the selected page. macOS and tvOS show one
`DayList` for the day.

9. Only the middle page is ever at rest. When the person pages to a neighbor and the middle page
   goes away, the day moves to that neighbor and the selection returns to the middle, so paging
   can go on in either direction without end.
10. The map's day MUST be set when the selection changes, not derived from the selection and the
    day together, which are changed in two steps and would show a wrong day in between.
11. Each day's list starts at the top, whatever the offset of the page it was paged from.
12. A day with no shows shows "No Shows Today" with "Check again tomorrow." when it is today, and
    "No Shows" for any other.
13. The title is relative: Yesterday, Today, Tomorrow, or On Date, followed by the day.
14. The Today tab's badge is the number of shows today, and is absent when there are none.

### The day being shown

The day the screen shows is `ArchiveTabState.dayOfLeapYear`. It is not saved: a launch starts on
today, and it is not in the navigation state ([RFC 004](004-archive-path-category-navigation.md)). The state starts from `Date.now`, and is
set to the model's day when the screen appears.

15. The shown day MUST return to today when `todayDayOfLeapYear` changes, so a screen left on
    last week's page doesn't stay there at midnight.
16. It MUST also return to today when the Today tab is chosen while Today is already selected.
    A tab's value includes the real today for Today (`TabSelection`), and the state keeps the paged
    day, so a tap on a paged Today is a real change of selection, and resets the day.
17. A link, Handoff or intent that names Today MUST show today, not the day it was paged to. It
    does so by changing a counter (`todayRequest`), because navigating to a category that is
    already selected changes nothing ([RFC 003](003-navigation-entry-points.md)).
18. A category shown from elsewhere keeps the day Today was paged to. Only the request above, a
    new day, the tab tap, and the screen appearing reset it.

## Rationale

- **A number, not a date.** The question is "which shows were on this date", for any year. A
  single integer is a key that needs no year, gives the days a fixed order, and makes the
  precomputed map ([RFC 006](006-precomputed-music-data.md)) a plain lookup.
- **Leap-year numbering.** Counting every year as if it had a 29th of February keeps March 1st the
  same number, so a show from a leap year and one from another year on that date meet.
- **February 29th is reachable.** It is a real date with real shows. Paging reaches it in every
  year, though it is never "today" except in a leap year.
- **Two ways to learn the day changed.** A notification covers an app that's running. A refresh at
  activation covers one that was asleep at midnight.
- **A counter to ask for today.** Today's identity is its tab, which can already be selected, so
  a change of state has to come from somewhere other than the selection.

## Open questions

- **A badge at midnight.** The badge counts shows for `todayDayOfLeapYear`, so it changes when
  the model's day does, not at the instant the calendar's does.
