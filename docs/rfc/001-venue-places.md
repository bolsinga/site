# RFC 001: Venue Places

Status: Accepted · Updated: 2026-11-17 · Code: `Sources/Site/VenuePlaces`

## Summary

Venue Places is a Debug-only macOS window for cleaning up the archive's venue data. It lists every
venue, checks each against Apple Maps and its website, and lets a person pick a better place,
address or website for it. Changes are kept in the window until they are saved as `venuemap.txt`,
which `web_generator` reads to rebuild the archive.

## Motivation

Venues are located by geocoding the address text in the archive, which often lands on the middle of
a city or on another venue. Fixing that means choosing a Maps place per venue, noticing addresses
and websites that are wrong, and feeding the result back to `web_generator`. There are many
venues, Maps limits requests, and the tool is only needed until the data is clean.

## Design

### Window

1. The tool MUST only exist in Debug builds on macOS (`VenuePlaces.isEnabled`). It is a `Window`
   scene opened from the Window menu.
2. The window MUST be one list of every venue, sorted by sort name, with a detail page for the
   selected venue. There is no dashboard, and no bulk accept: the detail page is the only place
   that changes a venue.
3. The list MUST show a status icon per venue. The filter menu MUST apply one filter at a time, and
   choosing it again turns it off; with none on, every venue shows:
   Modified, Suggested, No Street (City Center), Shares a Location, No Website, Website Needs a
   Look, No MapKit Identifier, Address Differs from Maps, Identifier Changed, Place Gone.

### What a person can change

4. A venue's page can make three changes, each kept in memory only (`PickStore` with no file):
   - **Place** (`VenuePick`): a Maps place by identifier, a pin, or "no place".
   - **Address** (`VenueAddress`): Maps' address replaces the street, city and state.
   - **Website**: the archive's, Maps', where either redirects to, or one typed in.
5. Maps' suggestions (a place, Maps' address, Maps' website) MUST be shown as suggestions. None may
   replace the venue's value unless the person chooses it.
6. Edits MUST NOT be saved between sessions. Any change marks the window edited, the way a
   document's is, until it is saved.

### Saving

7. Save and Save As MUST be in the File menu (⌘S, ⇧⌘S). The first save in a window asks for the
   folder; later saves reuse it, and the folder is not remembered after the window closes.
8. `VenueMapFile` writes one `venuemap.txt` line per venue, in ID order:
   `id*name*city*state*street*url*sortname*mapkit=IDENTIFIER`. Empty fields are left out. An
   accepted address replaces the street, city and state; a picked website replaces the URL; an
   unpicked venue keeps the archive's identifier; "no place" and pins write no identifier.
   `web_generator` passes every field through to the archive's JSON, so all of them take effect.
   The web site shows the address, groups venues by city, and links to the venue by its identifier,
   or to an Apple Maps search for its address when there is none. An accepted address that changes
   a venue's city therefore moves it to another city on the web site.
9. Closing the window, or quitting the app, with unsaved changes MUST ask first. It offers Save
   only once a folder has been chosen, so a cancelled folder choice cannot discard edits.

### Checks and caches

10. After the app's own geocoding finishes, one run does three batches, one after another:
    verify each venue's place identifier; search Maps for a place for each venue with no identifier
    and no pick; load each venue's website. **Run Checks Again** redoes everything.
11. Repeated Maps requests MUST go through `Atlas` (a throttle) or `MapItemLookup`; see RFC 002.
    Websites are not MapKit, so they load eight at a time.
12. Results are cached in the Caches directory as `venue-checks.json`, `venue-suggestions.json` and
    `venue-web-checks.json`, each with the date it was checked. A result is asked again when the
    thing it was checked for changes (the identifier; the venue's name and address; the website and
    name), or when it is older than `CacheAge.maximum` (30 days), or has no date.
13. A suggested place is rated strong, likely or weak by `PlaceSuggester`: strong when the name
    matches and the place is within 75 m or has the same street number; likely for a name match
    alone, or a venue-like place near and at the same number; weak for a venue-like place near or
    at the same number. A venue with no street geocodes to its city's center, so distance doesn't
    count for it.

## Rationale

- **Not a `DocumentGroup`.** It would add document types to the shipping app's `Info.plist`, own
  the save panel and file name (`venuemap.txt` must be exact), need a `venuemap.txt` reader, and
  expect to be the app's first scene. A plain window with a File-menu Save,
  `dismissalConfirmationDialog` and the window's edited state gives the same feel.
- **No saved picks, no "Clear Saved Data".** "Saved data" was confusing; the archive is the source
  and `venuemap.txt` is the output. The caches only hold what Maps and websites said, so they need
  an age, not a button.
- **Cache age, not the `shows.json` date.** That date changes with every show and says nothing
  about Maps changing.
- **No bulk operations.** Accepting many venues at once is too easy to get wrong; each change is
  one venue, one button.
- **One list instead of a dashboard.** Per-check cards listed a venue in several places and made
  it unclear what was being changed.
- **Maps' website is a suggestion.** The venue's own address is the archive's truth, so Maps'
  replaces it only when the person says so.

## Non-goals

- Renaming venues. The shows file refers to venues by name, so renames wait for the move to a
  database, which will make venue IDs the key.
- Writing pins to `venuemap.txt`, until it has a coordinate field.
- Long-term support. The tool is used heavily now and little later, so keep it simple.

## Open questions

None.
