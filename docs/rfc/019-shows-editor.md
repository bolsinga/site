# RFC 019: The shows editor

Status: Accepted · Updated: 2026-11-24 · Code: not written yet. Planned: `Sources/Site/ShowsEditor`

## Summary

The shows editor is a Debug-only macOS window for adding shows to the archive, and the artists and
venues they need. It opens the shows file, `shows.json`, from web_generator's data folder, keeps
changes in memory, and saves them back through `ShowsFile`. The file, its IDs and its checks are
[RFC 018](018-shows-file.md); this RFC is the window. It follows Venue Places
([RFC 001](001-venue-places.md)) wherever it can.

## Design

### Window

1. The editor MUST exist only in Debug builds on macOS, like Venue Places, as a `Window` scene
   opened from the Window menu.
2. It opens `shows.json` from web_generator's data folder ([RFC 018](018-shows-file.md), rule 7).
   The folder is chosen the way Venue Places chooses one ([RFC 001](001-venue-places.md), rule 7):
   on first use in a window, and not remembered after the window closes.

### Adding

3. **New Show** is a form:
   - **Date**: year, month and day, each of which may be unknown (`PartialDate`).
   - **Venue**: search the existing venues by name, using library order. Or **New Venue**: name,
     city, state, street, website, and a Maps place found the way Venue Places finds one
     ([RFC 002](002-mapkit-geocoding.md)).
   - **Artists**: an ordered list, headliner first, that can be reordered. Each one is found among
     the existing artists, or added as a new artist with a name and optional sort name.
   - **Comment**: optional text.
4. **New Artist** adds an artist with no show: a name and an optional sort name. It is for an artist
   web_generator reports as missing from iTunes ([RFC 018](018-shows-file.md), rule 13).
5. A new show, venue or artist gets its ID from `Music+NextID` ([RFC 018](018-shows-file.md),
   rule 8) when it is added, so the form can show it.
6. A new artist or venue's sort name is typed in, or left out. A new artist with accented letters
   and no sort name gets one derived for it ([RFC 018](018-shows-file.md), rule 12).

### Editing and saving

7. Until the file is saved, a new show, artist or venue can be edited or removed. After the save,
   it is part of the archive.
8. Edits are kept in memory only, as in Venue Places. The window is marked edited until it is
   saved, and closing it, or quitting the app, with unsaved changes asks first.
9. Save MUST be in the File menu (⌘S) and MUST write with `ShowsFile.write`. When `ArchiveCheck`
   reports problems, nothing is written, and the window lists every problem with the show, artist
   or venue it is about, so each can be fixed.
10. After a save, the window shows each new show's URL path (`/dates/shN.html`), so it can be
    checked once the site is rebuilt.

## Rationale

- **A Debug window.** It follows Venue Places: one person edits the data, on a Mac, and the shipping
  app stays a viewer.
- **Not a `DocumentGroup`.** The same reasons as Venue Places (RFC 001): it would add document types
  to the shipping app and own the file's name, which must be exactly `shows.json`.
- **IDs shown when added.** The ID is the show's URL, so seeing it before saving lets the person
  check it, and find the page afterward.
- **All problems at once.** A save that stopped at the first problem would need a save per fix.

## Non-goals

- Changing or deleting a show, artist or venue once saved. Fixes go through the file until there
  is a need for more.
- Editing relations.
- iOS, iPadOS and tvOS.

## Open questions

None.
