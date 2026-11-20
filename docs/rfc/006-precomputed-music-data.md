# RFC 006: Precomputed music data

Status: Accepted · Updated: 2026-11-20 · Code: `Shared/Sources/Shared/MusicData` (`Bracket`,
`Tracker`, `Music`, `Lookup`, `Vault`, `Ranking+Compute`, `RankDigest`)

## Summary

Nearly everything the app shows about the archive (rankings, first and most recent shows, who
played where, the order of lists) is a function of the music file alone, and the file doesn't
change after it loads. So it is computed once, when the file is downloaded, and saved with the
data. A launch then decodes the result and derives nothing. [RFC 005](005-music-loading.md) is when the file is
downloaded and when the saved result is read instead.

## What is computed

`Bracket.init(music:timestamp:)` runs once per download, off the main thread, doing the
independent pieces concurrently. `Tracker` walks the shows in date order and builds the indices
and rankings. The `Bracket` holds:

- **Rank digests** for every artist, venue, year and day of the leap year (`RankDigest`): its
  rank by number of shows, by span of dates, and by the artists or venues associated with it;
  its first and most recent show; and its library section. Equal values share a rank, and the
  next value takes the next rank, with none skipped.
- **Counts** of artists and venues that have a first show.
- **Relationships**, in both directions: shows of an artist, of a venue, of a year, of a day;
  artists at a venue; artists and venue of a show, headliner first; related artists and venues.
- **The records** themselves, by `ArchivePath`.
- **Sort tokens** for artists and venues, so two of them compare without touching their names.

`Lookup` and `Vault` are read-only views over it, and add no state that the music doesn't imply.

## Rules

1. A value that is a function of the music alone MUST be computed in `Bracket`, from `Tracker`,
   and saved with it.
2. A value that also depends on the user or the session MUST NOT be in `Bracket`. Where the user
   is, the current city, today's date, and what Maps says are in `VaultModel`.
3. `Bracket`, `Lookup` and `Vault` are immutable and `Sendable`, so a view can read them from
   anywhere without waiting on a load.
4. `Music` MUST NOT be saved. Only the `Bracket` is, so a read decodes derived data and runs no
   derivation.
5. `bracketCacheVersion` MUST be bumped whenever what is saved changes meaning or shape: the
   types inside it (`Show`, `Artist`, `Venue`, `RankDigest`), or what `Tracker` computes. A save
   removes the older versions' files, and a version that can't be found reads as a cache failure,
   so the next load downloads.
6. Artists with no shows are dropped before the `Bracket` is made, so no ranking counts them.

## Computed on load, on purpose

Two orders are functions of the archive alone, and are still made after the `Bracket` is read.
Rule 1 says what is computed in advance; these are the exception, because saving them gains
little.

- **Show order.** `Lookup` sorts every show once per load, to make `showIDOrderIndex`.
- **Library order.** `Vault` sorts every artist and every venue once per load, for paging.

## Computed per call, on purpose

These go through the whole archive each time they are asked for. Each is a function of the
archive alone, or of the archive and a filter, and each is left as it is because it costs little.

- **Counts per decade and year** (`decadesMap`), and the counts for a filter's shows
  (`decadesMap(showIDs:)`, which depends on the filter).
- **A rank distribution** (`rankDistribution`), when a stats screen is shown.
- **The new and most recent counts for a year**, when a year is shown.
- **Searches by name**, which match with `localizedStandardContains` on each keystroke, so they
  depend on the locale and the text.

Moving something into `Bracket` is a cache version bump (rule 5).

## Rationale

- **Derived data, not the source.** The rankings can't be had without walking all of the file.
  Saving the result pays that once for each change to the archive instead of once for each
  launch.
- **Why they can be precomputed.** The archive doesn't change after it loads, and a new version
  replaces it whole, so a ranking is right until then.
- **Kept out of the `Bracket`: the session.** What depends on where the user is or what day it
  is changes while the archive doesn't, so saving it with the archive would make it wrong.
- **Why the orders aren't saved.** On a synthetic archive of 6,000 shows, 2,500 artists and 600
  venues, both sorts together took about 90 ms, against about 140 ms to decode the `Bracket`.
  A saved order is as many paths again to decode and index, so it would save a fraction of that,
  make the file larger, cost every user a download for the version bump, and have to be kept in
  step with the comparator.
- **Why these aren't saved.** On a synthetic archive of 6,000 shows, 2,500 artists and 600
  venues, a rank distribution took 0.5 ms, the four counts for a year 0.2 ms, `decadesMap`
  0.02 ms, `decadesMap(showIDs:)` with half the shows 0.8 ms, and a name search over artists and
  venues 2.3 ms. Each is run when a screen appears or a key is typed, not for each frame, so a
  cache would add stored state to `Lookup` for no gain anyone could see. A filter and a search
  string can't be saved ahead of time at all.
- **The version.** A saved `Bracket` from a build that computed something differently would be
  read without complaint and show wrong numbers, so a change to the computation has to
  retire it.
