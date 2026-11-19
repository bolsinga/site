# RFC 003: Navigation and entry points

Status: Accepted · Updated: 2026-11-19 · Code: `Sources/Site/Music/UI` (`SiteView`, `ArchiveStateView`,
`ArchiveNavigation`, `ArchiveNavigation+External`, `ExternalEvent`, `ArchiveNavigationUserActivityModifier`),
`Sources/Site/Music` (`NSUserActivity+*`), `Sources/Intents`, `Sources/App` (`SiteAppDelegate`,
`SiteSceneDelegate`), `SiteWidgets`

## Summary

The app can be opened from many places: a link, Handoff, an App Intent, Siri, Spotlight, a widget,
or an iOS Home Screen quick action. They all arrive in different forms, but each one names an
`ArchivePath` (a page) or an `ArchiveCategory` (a tab's list), and each one ends in the same
call on `ArchiveNavigation`. This RFC is how an event gets there, and the rules that keep one
entry point from needing its own navigation code. It presumes the definitions of `ArchivePath`
and `ArchiveCategory`, their URL, string and `NSUserActivity` forms, and `Vault.url(for:)`, which
are in their own RFC.

## Entry points

| Entry point | Arrives as | Names |
|---|---|---|
| Universal link, or a link the app opens itself | `onOpenURL` | path or category |
| Safari, or a link opened by Handoff from the website | `NSUserActivityTypeBrowsingWeb`, its `webpageURL` | path or category |
| Handoff from another copy of the app | `NSUserActivity` of `ArchivePath.activityType` or `ArchiveCategory.activityType` | path or category |
| Open Artist, Open Venue, Open Concert intents | the entity's `url`, as a URL | path |
| Open Category intent, and its Siri phrases | `OpenURLIntent` with the category's URL | category |
| Spotlight | the indexed entity's `url`, or a continued `NSUserActivity` | path |
| Shows Today widget | `widgetURL`, or a `Link` to a show | category, or path |
| iOS quick action | a shortcut item, turned into a category `NSUserActivity` | category |

The app has no URL scheme of its own. Its URLs are the website's (`applinks:www.bolsinga.com`), so
a page in the app and the same page on the web have the same address.

## Rules

1. Every entry point MUST resolve to an `ArchivePath` or an `ArchiveCategory`, and MUST then call
   `ArchiveNavigation.navigate(to:)`, or `navigate(toRootOf:)` for a link to a category. Nothing
   else changes the tab or the path. An entry point MUST NOT push a view, or set a tab, itself.
2. A URL MUST be tried as a path first and as a category second. A URL that is neither MUST be
   ignored, and logged.
3. `ArchiveNavigation` MUST NOT see a raw event. `SiteView` turns each one into an `ExternalEvent`
   at the scene root, and `ArchiveStateView` hands it on once the vault has loaded. An event that
   arrives first (a cold launch, a widget tap) waits; only the latest waiting event is kept.
4. UIKit-only events MUST be turned into the same `NSUserActivity` SwiftUI is given for Handoff,
   so the app has one path for them. The quick action is the only one today.
5. A quick action on a cold launch MUST wait until the scene is active, so SwiftUI is listening
   when it is handed over.
6. A link to a category MUST show that category's list with nothing pushed onto it. A link to a
   path MUST NOT clear the other tabs. Navigating to the page already on top MUST do nothing.
7. Today is relative to the day it is shown, so any entry point that names Today MUST show today,
   not the day Today was last paged to.
8. Handoff to a category MUST also carry that category's sort, and apply it on arrival. Handoff
   to Venues MUST show the list, because a map has no sort.
9. Every page and category the app shows MUST advertise an `NSUserActivity` for what is on top of
   the stack, with the web URL when the vault has one. The activity's type MUST be listed in
   `NSUserActivityTypes` in `Info.plist`.
10. An intent or an entity MUST open a page by its URL (`URLRepresentableEntity`,
    `OpenURLIntent`), so it goes through the same code as a link. An intent MUST NOT depend on the
    app's navigation types. Intents that only answer, like `ShowConcerts`, don't open the app at
    all.
11. A widget MUST link by URL. The widget's URL is a category; a row's URL is a path. A row
    without a URL falls through to the widget's, so a tap always opens something.
12. An entity MUST use the page's `ArchivePath` as its identifier, so an entity from an intent or
    Spotlight and a page the app is showing are the same thing. The spotlight index MUST be
    replaced when what it holds changes (`spotlightIndexVersion`), and when the vault does.

## Rationale

- **One funnel.** Each new way in is a few lines that make a URL or an activity. Everything after
  that is shared, so a fix to how a link is shown fixes it for the widget, Siri and Handoff.
- **The website's URLs.** There's nothing to keep in step with the web: a link the app makes
  works in Safari, and a web link works in the app. It also gives Spotlight and Handoff a
  `webpageURL` for free.
- **Wait at the scene root.** The vault loads after the scene starts, and the navigation state
  is restored from the scene's storage. An event handled before then would be lost, or undone by
  the restoration.
- **Why quick actions become activities.** The iPhone supports one scene, so asking UIKit for a
  new scene fails. Handing the scene the same activity Handoff would is what already works.
- **Roots versus pages.** A tap on the widget header is a request for the list, not for whatever
  page was left open on that tab.
- **Today's counter.** Navigating to a category that is already selected changes nothing, which
  would leave Today on an older day. A counter that changes with each request does.
- **Dispatch workaround.** Changing the tab and the path together clears the path, so a category
  change is applied first, without animation, and the path on the next turn of the run loop.
  Tests turn this off so changes are immediate.

## Platform differences

- Quick actions are iOS only. tvOS has no widgets, no Spotlight indexing and no
  `handlesExternalEvents`; those are `#if !os(tvOS)`.
- On macOS, `handlesExternalEvents(preferring: ["*"], allowing: ["*"])` sends events to the
  existing window instead of opening another one.
- Lock Screen widgets (`accessory*`) exist only on iOS. They link the same as the others.

## Adding an entry point

1. Make a URL, or an `NSUserActivity` of an existing type, that names a path or a category.
2. Deliver it to `SiteView` so it becomes an `ExternalEvent`. If the system will only hand it to
   UIKit, convert it as the quick action does.
3. Don't add a case to `ArchiveNavigation`. If a new kind of destination is needed, it is a change
   to `ArchivePath` or `ArchiveCategory`, and to their RFC.
