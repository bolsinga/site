# RFC 004: ArchivePath, ArchiveCategory and ArchiveNavigation

Status: Accepted · Updated: 2026-11-19 · Code: `Shared/Sources/Shared/MusicData` (`ArchivePath*`,
`ArchiveCategory*`, `Vault`), `Sources/Site/Music/UI` (`ArchiveNavigation`, `ArchiveCategoryStack`,
`ArchivePath+Destination`, `ArchiveStateView`)

## Summary

Everything the app can show is named by one of two values. An `ArchivePath` names a page: a show,
a venue, an artist or a year. An `ArchiveCategory` names a tab and its list. `ArchiveNavigation`
holds which category is selected and the stack of paths pushed in each one. Links, Handoff,
intents, Spotlight and widgets reach the app by making one of these two values, which is the
subject of [RFC 003](003-navigation-entry-points.md). This RFC defines the values, their forms, and the state that holds them.

## ArchivePath

```swift
enum ArchivePath: Hashable, Sendable {
  case show(ID), venue(ID), artist(ID), year(Annum)   // ID is a String
}
```

The IDs are made by the website generator and already begin with the kind of page: `sh`, `v` or
`ar`. A year's ID is an `Annum`: a year, or `unknown` for shows with no year.

### Forms

A path has three string forms, chosen with `formatted(_:)`, and each has a parser.

| Form | Is | Used for |
|---|---|---|
| `.json` | the kind and the ID: `ar-…`, `v-…`, `sh-…`, `y-2001` | `Codable`, saved navigation state, an activity's `targetContentIdentifier` and `userInfo` |
| `.rawID` | the ID alone; a year is its `.json` form | App Intents entity identifiers |
| `.urlPath` | the page's path on the website | URLs |

`.urlPath` is `/bands/ID.html`, `/venues/ID.html` and `/dates/ID.html`. A year is
`/dates/<year>.html`, and the unknown year is `/dates/other.html`. `url(using:)` puts that path on
a root URL, and `Vault.url(for:)` does so with the archive's root.

### Parsing

1. The `.json` parser MUST read what the `.json` form writes, and be the only one used for saved
   state. The `.rawID` parser MUST tell the kind from the ID's own prefix, so it can't read a year.
   An entity can't name a year.
2. The URL parser MUST accept only `https` and a path of exactly two components ending `.html`.
   The directory gives the kind (`bands`, `venues`, `dates`), and the ID MUST start with that
   kind's prefix. A fragment, when there is one, is the ID in place of the filename.
3. The URL parser doesn't read year pages. A link to one is not a path, and falls to the category
   parser, which doesn't accept it either, so it is ignored.
4. A parser MUST throw for what it can't read. Callers use `try?` and ignore the rest; nothing
   guesses a path.

### Category of a path

`ArchivePath.category` is the tab a page belongs in: shows and years are in `.shows`, venues in
`.venues`, artists in `.artists`. No path belongs to `.today`, `.settings` or `.search`.

## ArchiveCategory

`today`, `shows`, `venues`, `artists`, `settings` and `search`, with `today` the default. Its raw
value is its stable name, used for Handoff and quick actions, so it MUST NOT be renamed. The
title, the symbol and the localized name are properties of it; views MUST use them rather than
keep their own.

A category has a website URL, `/dates/today.html`, `/dates/stats.html`, `/venues/stats.html` and
`/bands/stats.html`, and `Vault.url(for:)` has one for each, made when the vault is. `settings`
and `search` format as `/settings.html` and `/search.html`, but the URL parser reads only the
first four, so no link can name them.

Only `shows`, `venues`, `artists` and `today` hold pages. `settings` and `search` are never
given a path.

## ArchiveNavigation

`ArchiveNavigation` is `@MainActor` and `@Observable`. Its `State` is `Codable`, and is what the
scene stores for restoration, as sorted-key JSON.

```swift
struct State { var category: ArchiveCategory
               var todayPath, showsPath, venuesPath, artistsPath: [ArchivePath] }
```

### Rules

1. Each of the four categories MUST keep its own stack. Changing the category MUST leave the other
   stacks as they are, so going back to a tab finds it as it was left.
2. `path` is the stack of the selected category. For `settings` and `search` it is always empty.
3. Pushing a page from the UI is the `NavigationStack`'s own binding, not a call here. A stack
   shows its pages with `navigationDestination(for: ArchivePath.self)`, so any view can link to a
   path and one `destination(…)` decides what it shows, whichever tab the page was reached from.
4. `navigate(to: path)` MUST select `path.category` and make `[path]` that category's stack. It
   replaces the stack, because a link names one page, not a trail to it. It MUST do nothing
   when `path` is already the top of the selected stack.
5. `navigate(to: category)` MUST select the category and leave its stack. `navigate(toRootOf:)`
   MUST also empty it.
6. A path MUST NOT be a link in a page that already holds it earlier in the stack. `isPathNavigable`
   drops the last page before it looks, so the link doesn't flash on while going back.
7. The top of the selected stack, or the selected category when it is empty, is the app's
   current `ArchiveActivity`, which is what Handoff advertises.

8. Saved stacks MUST be pruned of pages the archive doesn't have each time an archive loads, so a
   restored scene never shows one. Pruning keeps the category and the other pages in order.
9. A page the archive doesn't have MUST still show something. `destination(…)` shows an Item Not
   Found screen, for any path that reaches it.

### Changing the category and the path together

Changing the category and a stack in one update makes SwiftUI clear the stack after the first
change. `change(for:)` says whether an update is `none`, an `assign`, or needs the workaround. For
the workaround the category is set first, without animation, and the stack on the next turn of the
run loop, with it. `useDispatchMainWorkaround` turns that off for tests, so changes are immediate.
That `DispatchQueue.main` call is the reason the class is `@MainActor`.

## Rationale

- **Two small values.** Every entry point needs the same two things: a destination, and a way to
  say it as a link, a string or an activity. A closed enum with `Codable` and format styles is one
  place to do that, and a compiler error everywhere a new kind of page isn't handled.
- **The website's shape.** A path's URL is the page's address on the website, so the app's links,
  Handoff's `webpageURL` and a link someone shares are the same, and the app reads its own links.
- **Three forms.** Saved state needs to be exact and include years. A system identifier has to
  be a plain ID. A URL has to match the website. They can't be one string.
- **One stack each.** The tabs stay independent, and a link to a venue doesn't discard a
  half-read artist page on another tab.
- **A link replaces the stack.** It names one page, not a trail to it.

## Adding to them

- **A kind of page:** a case on `ArchivePath` with its `.json` prefix, `.urlPath`, `category`,
  a `destination`, and its parsers. If it can't come from a URL or an entity, say so as years do.
- **A category:** a case, its URL and parser, a stack in `State` if it holds pages, and a tab.
  Saved state that no longer decodes is dropped and the scene starts fresh, so a new stack
  needs a custom decoder if that isn't acceptable.
