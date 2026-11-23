# RFC 012: Maps and clustering

Status: Accepted · Updated: 2026-11-22 · Code: `Sources/Site/ClusterMap` (`ClusterMap`, `SnapshotMap`,
`MKMapRect+Fit`, `ViewRepresentable`), `Sources/Site/Music/UI` (`ShowsMapHeader`, `VenuesMap`, `VenuesSummary`,
`VenuesMode`, `CategoryAnnotationView`, `OpenInMapsButton`), `SiteKit/Sources/SiteCore` (`MapItem+Geometry`)

## Summary

The app draws venues on two kinds of map. A **live** map (`ClusterMap`, an `MKMapView`) is the
Venues tab's map mode, where pins can be touched. A **snapshot** map (`SnapshotMap`, a still image
with dots) is the header behind the Shows pages and the Today pages, which is never touched. This
RFC is what each shows, how they get venue coordinates, how pins cluster, and the rules that keep
many maps cheap. How a venue gets a place in Maps is [RFC 002](002-mapkit-geocoding.md).

## What shows where

| Map | Where | Kind | Items | Taps |
|---|---|---|---|---|
| `VenuesMap` | Venues tab, `VenuesMode.map` | live | the venues the filter leaves, by search | a pin opens the venue |
| `ShowsMapHeader` | year, artist and venue pages (`PagedBrowser`) | snapshot | the venues of the page's shows | none |
| `ShowsMapHeader` | Today (`DayBrowser`), and a day's list (`DayList`) | snapshot | the venues of the day's shows | none |

A venue detail's header also has `OpenInMapsButton` (not on tvOS), which opens `mapsItem(for:)`.
Items come only from `VaultModel.venueMapItemMap`, the geocoded map items ([RFC 002](002-mapkit-geocoding.md)); the map
never geocodes. A venue with no map item is not drawn: `ClusterMap` drops invalid coordinates,
and `ShowsMap` skips the venue. While nothing is drawn and geocoding is running, a header shows a
progress view.

## Venues: map or list

`VenuesMode` is `map` or `grouped` (the list, and the default), kept per scene
(`@SceneStorage("venues.mode")`). Both modes use the same venues from the Nearby/City filter
([RFC 008](008-nearby-location-filter.md)), so the map grows as geocoding finishes.

1. The map MUST NOT be built until map mode is first chosen. After that it MUST be kept, hidden and
   inert (no hit testing, hidden from VoiceOver), when the list shows, so toggling back doesn't
   rebuild it.
2. The sort control is for the list only; in map mode there is none.
3. A category link that carries a sort ([RFC 003](003-navigation-entry-points.md)) MUST switch Venues to the list, since only the
   list is sorted.
4. Over the map the filter's message is a card and its progress a floating capsule ([RFC 008](008-nearby-location-filter.md)); a
   search with no matches shows "No Matches" in a capsule.
5. The map's search text follows typing after a 400 ms pause (not for the first), so the map
   doesn't re-fit per keystroke. The search's own results are shown wherever the map was moved.

## Navigation

6. Selecting a venue pin MUST navigate by `navigateToPath(item.id)` ([RFC 003](003-navigation-entry-points.md), [004](004-archive-path-category-navigation.md)), the same as a
   list row. The map pushes nothing itself.
7. Returning from a venue's detail MUST keep the map as it was left; any other appearance
   re-fits (a new `resetID`).
8. Shows headers are not interactive (`allowsHitTesting(false)`). Their content follows the
   pager: `PagedBrowser` and `DayBrowser` keep one header behind the pages and change its shows.

## Clustering

Clustering is MapKit's, by `clusteringIdentifier`; the code decides only whether to use it and
what a tap on a cluster does.

9. Live items MUST cluster when `clustersItems` is true (the default and `VenuesMap`'s choice):
   MapKit merges pins whose views overlap. The pin's title is drawn outside the pin's frame so
   it doesn't make pins cluster sooner. A cluster shows a count badge, and VoiceOver says
   "Cluster, N venues".
10. Tapping a cluster zooms to its members. If fitting them barely changes the zoom (the fit is
    over 80% of the visible width), it zooms by up to 4x to separate the closest pair, and if
    that is no change it zooms 2x on the cluster.
11. Members at one place (under one map point apart) can never separate, so a tap lists them
    by name (an action sheet on UIKit, a menu on macOS), and choosing one selects it.
12. A pin's title hides when it would cover another pin or a kept title; titles nearest the
    middle of the map are kept first.
13. A snapshot has no clusters: dots closer together than the dot (14 points) show as one, with
    no count, and the first venue's point wins.

## Fitting

14. A map fits all its items once the map has a size, and again when the set of items changes
    (by id), until the person moves it (`userMovedMap`); a new `resetID` starts over. A search
    with no match returns to where the map was before the search.
15. A fit pads the items by 10% of their width (100 meters if narrower, `MapItem+Geometry`), then
    zooms out by `fitZoomOutFactor`: 1 live, 1.3 for a header with `animatesChanges` (every pager header,
    Today included), and 2 for one without (`DayList`'s).
16. A fit MUST leave room for what covers the map: the safe area, the pin above its coordinate
    (`CategoryAnnotationView.tipOffset`), and, for a header with `animatesChanges`, the fade at the
    bottom (40% of its height). The live and snapshot maps both use `MKMapRect.fitted`.
    The live fit measures the first item's pin, so every pin and a cluster's MUST have the same
    frame. `CategoryAnnotationView` draws the count badge inside its frame: at the largest text
    size it allows (`accessibility1`) the badge reaches 0.5 points past the right edge and stays
    inside the bottom padding.

## Snapshots

17. A map that is never touched MUST be a snapshot. It keeps no tiles or render state, so having
    many costs little; the live map is used only where it is interacted with.
18. A snapshot is an `MKMapSnapshotter` image of the fitted rect, at the view's rounded size,
    scale and light or dark appearance, muted and without points of interest. Dots are SwiftUI
    views over it, so they follow the accent color.
19. Snapshots are cached in memory (`NSCache`, 30 MB by pixel cost), by a hash of the request:
    rect, size, appearance, scale and the dot coordinates. A request MUST be served from the
    cache before one is made, but only by a map whose own request equals it, since two requests
    can share a hash.
20. While a snapshot is shown, the pages either side have theirs made ahead, one at a time, after
    the shown one, and given up when the shown map changes, so paging shows a map at once.
21. A header with no venues keeps its last map without dots (at 0.3 opacity) when `animatesChanges`
    is true, and shows nothing otherwise. Changes fade in only when `animatesChanges`.

## Platforms

22. `ViewRepresentable` hides `UIViewRepresentable` and `NSViewRepresentable`, with hosting views
    for pin content, so `ClusterMap` is one type on all three.
23. Live maps disable rotation and pitch, guarded `#if !os(tvOS)`. Reduce Motion
    makes fits, zooms and fades instant.
24. `MapHeaderStyle` lets a page run under a transparent toolbar when it has a map header, and
    hides its title (`toolbar(removing: .title)`, not on tvOS), with an inline title on iOS.
    `DayList` applies it only when it has its own header, so Today's pager applies it once.
25. `OpenInMapsButton` and the venue place lookup (`findPlace`) are not on tvOS; the button
    does nothing there.

## Rationale

- **Two kinds of map.** A live map holds tiles and a render state, and a pager shows many headers.
  A still image is cheap, can be made ahead, and is enough where nothing is touched.
- **MapKit clusters.** Overlap of what is drawn is what the person sees, so it is the rule;
  titles are outside the frame so labels don't merge pins.
- **Keep the live map.** Building a map is the slow part of toggling, and a person who zooms
  expects to find it where it was.

## Open questions

- **Venue pins on tvOS.** Map mode and `UIAlertController` action sheets are not guarded for tvOS;
  whether they work there is not verified. See [#1732](https://github.com/bolsinga/site/issues/1732).
