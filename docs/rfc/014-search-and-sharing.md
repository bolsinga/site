# RFC 014: Search and sharing

Status: Accepted · Updated: 2026-11-23 · Code: `SiteKit/Sources/SiteUI` (`ArchiveCrossSearch*`,
`ArchiveSearchModifier`, `ArchiveScope`, `RankableSearchableSortList`, `ArchiveSharable*`,
`ArchiveCategorySharable`, `ArchivePathLink`, `ArchiveTabView`), `SiteKit/Sources/SiteCore`
(`String+AttributedMatching`), `SiteKit/Sources/SiteCore` (`VaultModel`, `NSUserActivity+Search`),
`Shared/Sources/Shared/MusicData` (`Nameable`, `Vault`, `TokenSearchError`)

## Summary

The app searches artist and venue names, in the Search tab and in the Artists and Venues lists. It
shares a page as its website URL. Both are in-app features. Siri and Spotlight finding an item is a
different path ([RFC 009](009-entities-siri-spotlight.md)); it shares only the Vault's name filter.

## What is searched

Only the `name` of an artist or venue. Shows and years have no search.

1. Matching MUST be `String.localizedStandardContains` on the name (`Nameable.filter(by:)`), so it
   is case and diacritic insensitive (full-width letters don't match ASCII ones), and the
   fragment may sit anywhere in the name.
2. An empty search string matches nothing in `Vault.artists(filteredBy:)`, `venues(filteredBy:)`
   and `artistIDs(filteredBy:)`, and everything in `Collection.names(filteredBy:)`, which the lists
   use. So the Search tab with an empty string lists nothing, and a list shows all its items.
3. `artistIDs(filteredBy:)` and `venueIDs(filteredBy:)` return IDs in dictionary order. The App
   Intents queries use them ([RFC 009](009-entities-siri-spotlight.md)), and MUST NOT rely on their order.

## Search tab

| | iOS, tvOS | macOS |
|---|---|---|
| Tab | `Tab(value:, role: .search)` | a plain tab with the category's title and image |
| Contents | a `NavigationStack` holding `ArchiveCrossSearchContainer` | the same |

1. The tab is the `.search` `ArchiveCategory`. It has no `ArchivePath` stack and no URL ([RFC 004](004-archive-path-category-navigation.md)):
   `ArchiveCategoryStack` draws `EmptyView` for it, and the tab builds its own stack.
2. `ArchiveScope` is `all`, `artist` or `venue`, offered by `.searchScopes`. `all` shows both
   sections, the others one. The scope and the string are `@State` in `ArchiveTabView`, so they
   survive a switch of tab and are not saved.
3. `ArchiveCrossSearchContainer` MUST draw its results only while `isSearching`.
4. A result is a row of the emphasized name and a trailing arrow, with a tap gesture that calls
   `navigateToPath` with the item's `ArchivePath` ([RFC 003](003-navigation-entry-points.md)).
5. With no match in either section and a non-empty string, the view shows
   `ContentUnavailableView.search`. Sections are titled by `ArchiveCategory.localizedString`, and
   an empty section is left out.
6. Results are sorted by `Vault`'s library order (`Lookup.compareIDs`), not alphabetically.

## Lists

`RankableSearchableSortList` backs the Artists and Venues lists in grouped mode. It filters its
items with `names(filteredBy:)`, hands them to `RankableSortList`, and applies
`archiveSearchable`: `.searchable` plus a `ContentUnavailableView.search` overlay when a non-empty
string leaves nothing.

1. Each category has its own string (`artistSearchString`, `venueSearchString` in
   `ArchiveCategoryStack`), separate from the Search tab's.
2. A list's result order MUST be the list's own sort and sections (`RankingSort`), filtered.
3. The Venues map filters with the same `names(filteredBy:)`, from a copy of the string that
   settles for 400 ms after the first change. It has its own `searchable` and "No Matches" label.

## Emphasis

1. `String.emphasizedAttributed(matching:)` MUST make only the first occurrence of the fragment
   bold, found as the filter finds it (`localizedStandardRange(of:)`, ignoring case and
   diacritics), so a row that passes the filter has its match emphasized. It returns the name
   unchanged for an empty fragment or no match. Leading and trailing spaces of the matched text
   stay plain; a match of only spaces is not emphasized.
2. Emphasis MUST be an attribute set on the name's text. A name MUST NOT be parsed as Markdown, so
   `*`, `_`, brackets, backticks and backslashes show as they are. Rows draw it with `Text`.
3. Emphasis is display only. Which rows appear is decided by the matching rules above.

## Errors

Sorting results calls `Bracket.compareIDs`, which throws `TokenSearchError.invalidCompareTokenID`
for an ID with no compare token. `VaultModel.artists(filteredBy:)`, `venues(filteredBy:)` and
`compare` MUST catch it, set `model.error`, and return no results (`false` for a compare).

## Sharing

A shared page is its website URL: `Vault.url(for: ArchivePath)` ([RFC 004](004-archive-path-category-navigation.md)), or for a category
`Vault.url(for: ArchiveCategory)`. `ArchiveSharable` supplies the text sent with it.

| Item | `subject` | `message` |
|---|---|---|
| `ShowDigest` | headliner and venue | the full show text |
| `VenueDigest` | "Shows at" and the name | the subject |
| `ArtistDigest` | "Shows with" and the name | the subject |
| `AnnumDigest` | the year, `.shared` format | the subject |
| `ArchiveCategorySharable` | the category's title | the subject |

1. `ArchiveSharableToolbarContent` MUST add a `ShareLink` at `.primaryAction` only when the URL is
   non-nil. The preview image is the app icon.
2. On tvOS it adds an empty item and no `ShareLink`.
3. The item is in `ArchiveCategoryToolbarContent` for every category stack, in `ShowDetail`, and in
   `PagedBrowser`, where it follows the page shown, so swiping pages changes what is shared.
4. `ArchivePathLink` is a `NavigationLink(value:)` only if `isPathNavigable(path)`, and the plain
   label otherwise.
5. On macOS, sharing by Mail shows no subject. The `subject` is still given, and iOS
   shows it.
6. `addSearchableContent(description:)` sets a Spotlight `contentDescription` on an
   `NSUserActivity` (not on tvOS). It is part of the activities in [RFC 003](003-navigation-entry-points.md), not of sharing.

## Not yet

- Recent searches, suggestions and saved searches.
- Searching shows, years, cities or comments.
- Sharing from the Search tab or from a list row.

## Open questions

- `SearchResultButton` is a tap gesture with the button trait, not a `Button`. Does it work with
  keyboard and tvOS focus? See [#1739](https://github.com/bolsinga/site/issues/1739).
- Whether a Search tab result also selects the page's category was not checked here ([RFC 003](003-navigation-entry-points.md), [004](004-archive-path-category-navigation.md)).
