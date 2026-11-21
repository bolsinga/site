# RFC 013: Rankings, first sets and library order

Status: Accepted · Updated: 2026-11-20 · Code: `Shared/Sources/Shared/MusicData` (`Rank`, `Ranking`,
`Ranking+Compute`, `RankDigest`, `RankDistribution`, `Rankable`, `RankedArchiveItem`, `RankingSort`,
`FirstSet`, `MostRecentSet`, `PartialDate+Span`), `Shared/Sources/Shared/Utilities` (`LibraryComparable`,
`LibraryCompareTokenizer`, `LibrarySection`, `String+LibrarySection`, `String+TokenCompare`),
`Sources/Site/Utility` (`Rank+FormatStyle`, `FormatStyle+Ranking`), `Sources/Site/Music/UI`
(`StatsCard`, `RankableSortList`, `RankingList`, `FirstSetLine`)

## Summary

What a rank, a first set, a most recent set and the order of a library list mean, and how a person
sees them. [RFC 006](006-precomputed-music-data.md) is where they are computed and saved, and [RFC 010](010-today-and-day-of-leap-year.md) is the day of the leap year
that days are ranked by. This RFC is the meaning, and the lists that show it.

## Ranking dimensions

A `RankDigest` has three `Ranking`s (a `Rank` and the value it came from) for an artist, venue,
year or day. What each counts depends on what is ranked.

| Dimension | Artist | Venue | Year | Day |
|---|---|---|---|---|
| `showRank` | its shows | its shows | its shows | its shows |
| `spanRank` | years from first to last date | years from first to last date | its venues | its venues |
| `associatedRank` | venues played | artists who played | its artists | its artists |

For a year and a day the span slot holds a count of distinct venues, not a time span, and only
the digest of an artist or a venue has a first set, a most recent set and a library section.

### Ties and ranks

1. Items with the same value MUST share a rank, the highest value being rank 1, and the next
   lower value MUST take the next rank, so no rank is skipped (dense ranking).
2. A `Rank` is `.rank(n)` or `.unknown`. `.unknown` MUST sort after every number, and a
   `Ranking` orders by its rank and then its value. A missing dimension is `Ranking.empty`
   (unknown, 0).
3. A year span MUST count the distinct dates (a `Set<PartialDate>`) that have a year: none is 0,
   and one date, or one dated and the rest undated, is 1. Otherwise it is the whole years
   between the earliest and the latest, never fewer than 1, and one year and any more time
   counts as 2. A date with no year is left out. Dates are read in `Calendar.archive`, so a span
   doesn't depend on the calendar of the device that made the `Bracket`.
4. A date with nothing known MUST NOT count toward a span or become a first or most recent
   date, though the show still counts toward the show rank.

## First set and most recent set

A `FirstSet` is the date an artist or venue was first seen and its order among all of them.

1. The shows are walked in date order, a date with nothing known last and shows on one date by
   id. The order is 1, 2, 3 in the order items first appear, so it is unique, unlike a rank.
2. An item whose dates are all unknown has no first set (`FirstSet.empty`, unknown order), and
   isn't counted in the order, so the orders run from 1 to the count of items that have one
   (`artistFirstSetCount`, `venueFirstSetCount`).
3. A date with only some of its parts sorts before a more specific one, so a year alone is
   earlier than any date in that year, and can be the first date.
4. `isFirst(on:)` is true for every show on the first date, not only one, and false for a
   date with nothing known. A show is "new" for an artist or venue by that.

A `MostRecentSet` is only a date, the greatest known date of the item, which has no order. By
rule 3, a year alone is before the dates in it, so it is the most recent only when nothing more
specific is later. `isMostRecent(on:)` is true for every show on it. A year's new and most
recent counts use the year of the first or most recent date, and a date without a year is in no
year.

## Library order

An artist or venue is ordered by a compare token made in advance ([RFC 006](006-precomputed-music-data.md)).

1. The token starts from `sortname`, or `name` without one (`librarySortString`).
2. A leading "The", "A" or "An" (any case, followed by whitespace) is removed. Then if what is
   left is words with only spaces, with punctuation before and after, that punctuation is
   removed too.
   Punctuation inside the name stops that: "AC/DC" and "(hed) pe" keep theirs, so "AC/DC" is
   under A, and "(hed) pe" is in the punctuation section, not under H.
3. Tokens compare ascending, ignoring case and diacritics.
4. The section is the token's first character: a digit is numeric, punctuation is
   punctuation, and anything else is that character in capitals. Sections sort the letters,
   then numeric, then punctuation.
5. Ids that tie MUST be ordered by id, numbers by value (`ar9` before `ar10`), by the comparator
   itself (`Bracket.compareIDs`), so every list, search and sort that uses it gives one order
   whatever order it started from. An id that can't be compared (`TokenSearchError`) is ordered by
   id in `Lookup.libraryOrder`, which makes the id lists a detail screen pages through. Shows
   order by date, venue, headliner by this order, and then id.

## Sorting lists

`RankingSort` has five cases, and all of them are on the Sort menu. A group is a section, and
each is ordered by library order.

| Sort | Groups | Group order | Row shows |
|---|---|---|---|
| Alphabetical | library section | letters, numeric, punctuation | show count |
| Show Count | `showRank` | rank 1 first | none |
| Year Range | `spanRank` | rank 1 first | show count |
| Associated | `associatedRank` | rank 1 first | none |
| First Show | first date | earliest first, unknown last | `#` first set order |

Header of a group is the rank and its value ("#2  5 Show(s)"). Associated reads "Sort By Venue
Count" on Artists and "Sort By Artist Count" on Venues. Artists and Venues are the sortable
tabs, and Venues only in its grouped mode, not the map. The two choices are saved per scene
and start as Alphabetical. Search narrows the items before they are grouped.

## Showing a rank

1. `Rank` is formatted `#1` (`.hash`, the default) or `1.` (`.dotted`), with no grouping
   separator, and unknown is "Rank Unknown". `Ranking` is `#n` (`.rankOnly`) or `#n Count: v`
   (`.rankAndCount`).
2. A stats row MUST show nothing for an unknown rank, and the first set row for an artist or
   venue is only shown with a known one.
3. A stat row charts its rank against all of the kind with `RankDistribution`, a bar per rank
   as wide as the items that tie. The shows row is charted for every kind, the years row for
   artists and venues, the venues row for an artist (associated) and a year or day (span), and
   the artists row for a venue, year and day. Unknown ranks are left out.
4. The first set row reads as an ordinal ("12th Artist"), and its line puts a dot at
   (order − 1) ÷ (count − 1), at the start when there is one.

## Rationale

- **Dense ranks.** "#2" is always the second-highest value, so a tie doesn't hide the next
  rank, and a chart has one bar per distinct value.
- **First set as an order.** "12th Artist" says when an item joined the archive, which a tied
  rank couldn't, as each item has its own order.
- **Less specific dates first.** An item with a show in 2005 and another on a day in 2005 has
  2005 as its first date, so the show with no more date than that counts as the first.
- **Tokens, not names.** Skipping "The" and punctuation puts "The Who" under W.

## Open questions

- **Unused styles.** `.dotted` and `.rankAndCount` are defined but nothing in the app calls them. See [#1736](https://github.com/bolsinga/site/issues/1736).
- **Span for years and days.** The code names its venue count the span ranking, and its comment
  says the names don't quite work. See [#1736](https://github.com/bolsinga/site/issues/1736).
