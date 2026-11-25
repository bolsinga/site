# RFC 018: The shows file

Status: Accepted · Updated: 2026-11-24 · Code: not written yet. Planned: `SiteKit/Sources/SiteCore/MusicData`
(`ShowsFile`, `ArchiveCheck`, `Music+NextID`), `Sources/site_tool` (`NextIDCommand`)

## Summary

Shows are added today by editing text files by hand and running
[web_generator](https://github.com/bolsinga/web_generator), which makes the website and the JSON
this app reads. Under this RFC and [RFC 019](019-shows-editor.md), the app becomes where shows are
created. This RFC is the data: the **shows file**, `shows.json`, in the same format as the
website's `json/shows.json`; how new IDs are made; the checks every saved file passes; what
web_generator does with the file; and the move away from the text files. RFC 019 is the window
that edits it. Played music (albums and songs) stays with web_generator.

## Motivation

- A new show means editing `shows.txt` by name, and often `artistids.txt`, `bandsort.txt` and
  `venuemap.txt` as well. Names must match exactly, IDs are found by hand (`site_tool nextID`), and
  mistakes are only found when web_generator runs.
- The app already decodes this data, checks venues against Maps ([RFC 001](001-venue-places.md)),
  and writes `venuemap.txt` back for web_generator. Creating shows is the next step from there.
- The raw files refer to venues by name, which is why Venue Places can't rename a venue
  ([RFC 001](001-venue-places.md), Non-goals). In the JSON, shows refer to venues by ID.

## What web_generator expects

web_generator's `docs/rfc/` describes what exists today. The parts this RFC depends on:

- [002-inputs](https://github.com/bolsinga/web_generator/blob/master/docs/rfc/002-inputs.md): the
  JSON format, what each reader checks, and what another writer of the JSON must get right.
- [001-data-model](https://github.com/bolsinga/web_generator/blob/master/docs/rfc/001-data-model.md):
  which IDs are stable, how sort names work, relations.
- [004-verifying-output](https://github.com/bolsinga/web_generator/blob/master/docs/rfc/004-verifying-output.md):
  comparing two generated sites.

The facts that shape this design:

- Show, venue and artist IDs are website URLs (`/dates/shN.html`, `/venues/vN.html`,
  `/bands/arN.html`). They are also this app's `ArchivePath` IDs ([RFC 004](004-archive-path-category-navigation.md)),
  so they are in saved navigation, Handoff, Spotlight and widgets ([RFC 009](009-entities-siri-spotlight.md),
  [RFC 011](011-persisted-state.md)).
- web_generator's `json-site` reads one music file holding shows and iTunes data together. A
  shows-only file today gives artist pages with no albums, empty `tracks/` pages, and a home page
  with no song counts or last played song.
- `json/shows.json` already contains every venue, every artist (including artists known only from
  iTunes), every relation and every show, with `songs` and `albums` empty.
- web_generator's JSON reader takes `sortname` as written. Its raw reader derives one for artists
  whose names have accented letters.

## Design

### The file

1. The shows file MUST be the format of `json/shows.json`: a `Music` with `albums` and `songs`
   empty. The app writes it with its own `Music` types, so whatever the app writes it can read.
2. It MUST hold every artist, including artists with no shows, and every relation. The app loads
   it as `nextID` does today ([RFC 017](017-site-tool.md)), with `artistsWithShowsOnly: false`.
   Artists known only from iTunes keep their IDs here, because their pages are URLs too. See
   [Artists with no shows](#artists-with-no-shows).
3. `ShowsFile.write` MUST use `.prettyPrinted`, `.sortedKeys` and `.withoutEscapingSlashes`, and
   ISO 8601 dates, and MUST write `venues`, `artists`, `relations` and `shows` in ID order
   (`localizedStandardCompare`, as `VenueMapFile` does). The same data then gives the same bytes,
   so the file diffs well in git. web_generator sorts for itself, so order doesn't change the site.
4. `timestamp` MUST be the time of the write.
5. Optional values that are `nil` MUST be left out, which the synthesized `Codable` already does.
   An unknown part of a date is a missing key, and a wholly unknown date is `{}`. Never `0`.
6. Fields web_generator writes that the app does not model (`Venue.comment`, `Artist.location`
   and `Artist.comment`) are never set by web_generator's raw input, so the
   shows file drops nothing that exists. `ArchiveCheck` (rule 10) MUST fail a file that has them,
   so the assumption is checked, not trusted.
7. The file MUST be named `shows.json`, live with web_generator's other inputs (the folder passed
   to `site`), and be committed there. It has the same name and format as the website's
   `json/shows.json`, which web_generator goes on writing from it. The app reads it from that
   folder, not from the website: the website lags behind until web_generator runs and the site is
   copied up.

### IDs

8. A new show, venue or artist MUST get the next number after the highest one of its kind, with
   the kind's prefix (`sh`, `v`, `ar`). An ID MUST NOT be reused, even if its show, venue or
   artist was deleted: a reused ID makes old links, Spotlight items and saved navigation open
   something else.
9. `site_tool nextID` MUST change to the same rule, through the same `Music+NextID` code. This
   replaces RFC 017's "gaps first" rule, and RFC 017 is updated in the same PR.

### Checks

10. `ShowsFile.write` MUST run `ArchiveCheck` first, and MUST NOT write while it reports a problem.
    It checks:
    - IDs are unique within each kind, and start with their kind's prefix.
    - Every show's `venue` and `artists`, and every relation's members, are IDs in the file.
    - Every show has at least one artist.
    - Every venue is named by at least one show. An artist needs none (rule 2).
    - Dates are possible: month 1–12, and a day that exists in its month (in a leap year when the
      year is unknown).
    - Each relation's members are all artists or all venues.
    - No two venues have the same name, and no two artists have the same name. web_generator's raw
      files and iTunes join by name.
    - The fields of rule 6 are absent.
11. `ArchiveCheck` is a pure function of a `Music` that returns every problem it finds, so
    `SiteCoreTests` can test each one with a small `Music` built in code ([RFC 016](016-testing.md)).

### Sort names

12. When a new artist's name has accented letters and it has no sortname, it MUST get the sortname
    `name.decomposedStringWithCanonicalMapping`, which is what web_generator's raw reader derives.
    Existing sort names are written back unchanged.

### web_generator

13. web_generator needs a way to make the site from the shows file, its iTunes data and the diary
    files. That is web_generator's change, described in its own RFC. What this RFC needs from it:
    - Albums and songs from iTunes are joined to the shows file's artists by name.
    - An iTunes artist not in the shows file stops the run with its name, as missing artist IDs do
      today. The person adds it with **New Artist** ([RFC 019](019-shows-editor.md)), and runs
      web_generator again.
    - The shows file's sort names win over iTunes'.
    - The same checks as rule 10, so a file not written by the app is also checked.

### Migration

14. In order:
    1. web_generator gains its new input (rule 13). Making the site from the raw files and from the
       `json/shows.json` they export MUST give the same HTML, compared with `diff -r` as in
       web_generator's RFC 004, leaving out what that RFC lists as changing from run to run. Only
       the HTML must match. The site's other files, including the JSON exports in `json/`, may
       differ: key order, `timestamp`, and the order of artists and venues are not part of the
       contract.
    2. The app gains `ShowsFile`, `ArchiveCheck` and `Music+NextID`. Reading today's
       `json/shows.json` and writing it again MUST give a file that decodes equal to the original.
       `ArchiveCheck` MUST pass on it.
    3. The shows file is made by copying the website's `json/shows.json` into the data folder and
       writing it once with `ShowsFile`. From then on, `shows.txt`, `venuemap.txt`,
       `bandsort.txt`, `artistids.txt` and `relations.txt` are no longer edited, and web_generator
       is run with the new input.
    4. The editor ([RFC 019](019-shows-editor.md)) follows. Venue Places then saves its changes into
       the shows file's venues instead of `venuemap.txt`, which makes renaming a venue possible;
       RFC 001 is updated with that change.

## Rationale

- **Same format as `shows.json`.** The app already decodes it, web_generator already writes it,
  and the website already publishes it. No new format, and the first shows file is the one the
  website already has.
- **The name `shows.json`.** The file is the website's `json/shows.json`, moved to where it is
  edited. One name for one format; the folder says which copy it is.
- **Shows apart from iTunes.** The app models only part of `Album` and `Song`, and not
  `Song.live` or `Album.purchase`. Writing the full `music.json` would mean modeling all of
  iTunes' data to pass it through. Keeping iTunes data with web_generator keeps this change to
  what the app understands.
- **Every artist in the file.** Artist IDs come from one place, the app, rather than the app
  for some artists and `artistids.txt` for others. See
  [Artists with no shows](#artists-with-no-shows).
- **Highest plus one, not gaps.** Gaps are IDs that were published. Dense numbers don't matter;
  URLs that stay put do.
- **Sorted, stable output.** The shows file becomes the archive's history in git, so a change
  should be a small diff.
- **Checks in the writer.** Every way of saving the file, the editor's or any later one, goes
  through `ShowsFile.write`, so none can skip them.
- **A venue needs a show.** web_generator makes a page for every venue that lists its shows, and
  stops the run on a venue with none. Checking it here keeps the app from writing a file that
  web_generator rejects, for example once a venue's last show is removed or moved to another venue.
  Artists differ: an artist with no shows is fine, as iTunes-only artists are.
- **Only the HTML must match.** The HTML is what people see and link to. The JSON exports are
  read by this app, which doesn't depend on their key order or byte layout.

## Non-goals

- The editor window. That is [RFC 019](019-shows-editor.md).
- Albums, songs, and anything else from iTunes, for now. See [Later: iTunes in the app](#later-itunes-in-the-app).
- The diary. web_generator keeps reading `comments.txt` and `statics.txt`.
- Editing relations. They are written back as read.
- Generating or uploading the website. web_generator and the rsync step stay as they are.

## Artists with no shows

Some artists are known only from iTunes: there are albums by them, but no show. web_generator makes
a page for each (`/bands/arN.html`, listing the albums), so their IDs are URLs like any other
artist's. Today they get IDs the same way as every artist, from `artistids.txt`, and
`json/shows.json` includes them. Relations can name them too; `Music+ShowsOnly` removes them only
for the viewer.

Rule 2 keeps them in the shows file. The choice not taken is for web_generator to keep owning
them, for example with `artistids.txt` cut down to just these artists, and for the shows file to
hold only artists with shows.

| | Shows file has every artist (rule 2) | web_generator owns artists with no shows |
|---|---|---|
| Who makes `ar` IDs | the app alone | the app and web_generator, from one numbering, so each must know the other's highest number |
| First show by a band already in iTunes | the editor finds the artist; its ID, and its page's URL, stay the same, and the page gains the show | the app doesn't know the artist, so it makes a new ID. web_generator then finds the same name in both places and must pick one ID; picking the app's moves the page to a new URL |
| A new artist in iTunes (an album by someone never seen) | web_generator stops and names the artist, as it does today for missing IDs; the person adds it in the app | web_generator gives it an ID itself; nothing changes in the app |
| Relations that name such artists | stay in one file and are checked by `ArchiveCheck` | refer to artists in another file, so `ArchiveCheck` can't check them, and web_generator joins relations from two places |
| What the app holds | artists it doesn't show | only what it shows |

The first and second rows are why rule 2 was chosen: one owner for IDs, and a band's page keeps
its URL when it goes from albums only to albums and shows. The cost, accepted, is the third row: a
new iTunes artist stops web_generator until it is added in the app with **New Artist**
([RFC 019](019-shows-editor.md)). web_generator does not make an ID for it and leave it to be
copied back later, because then two places would make `ar` IDs.

## Later: iTunes in the app

Once this is working, the app will read the iTunes data itself. It can then find artists that are
in iTunes but not in the shows file, and give them new `ar` IDs on its own, with the rules for IDs
(rules 8 and 9) and the checks (rule 10) unchanged. That removes the cost above: web_generator no
longer stops for a new iTunes artist, because the shows file already has it, and **New Artist** is
left for artists that are typed in by hand.

Rule 2 is what makes this possible. The app already owns every artist ID, so adding iTunes artists
is one more way the app makes IDs, not a second owner. That later change gets its own RFC, which
also says whether albums and songs move to the app or stay with web_generator.

## Open questions

None.
