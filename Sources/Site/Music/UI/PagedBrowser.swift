//
//  PagedBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 10/26/26.
//

import SwiftUI

extension Collection where Element: Hashable {
  /// The elements either side of `element` in this ordered collection. The ends wrap: before the
  /// first is the last, and after the last is the first. An element that is not here is its own
  /// neighbor.
  func wrappingNeighbors(of element: Element) -> (previous: Element, next: Element) {
    let ordered = Array(self)
    guard let index = ordered.firstIndex(of: element) else { return (element, element) }
    let previous = ordered[(index + ordered.count - 1) % ordered.count]
    let next = ordered[(index + 1) % ordered.count]
    return (previous, next)
  }
}

/// An item's details that can be paged to the previous and next item, like the Today pager. One
/// header stays behind the pages, and its content changes as the pages are paged.
struct PagedBrowser<Item: Hashable, Digest: ArchiveSharable, Header: View, Page: View>: View {
  let item: Item
  let neighbors: (Item) -> (previous: Item, next: Item)
  let digest: (Item) -> Digest?
  let url: (Digest) -> URL?
  let title: (Item, Digest?) -> String
  /// Called with the item the pager settles on, so the navigation path names the item shown.
  let didShow: (Item) -> Void
  /// The header for an item, given its neighbors' digests to have ready for paging.
  @ViewBuilder let header: (Item, Digest?, [Digest]) -> Header
  /// A page for an item's digest, given room to leave clear under its last card.
  @ViewBuilder let page: (Digest, CGFloat) -> Page

  /// How far above the bottom of the pages the system page dots reach, which a page leaves clear
  /// under its last card, as `DayBrowser` does.
  private static var pageDotsClearance: CGFloat { 44 }

  enum PageTab: Int {
    case previous
    case current
    case next
  }

  @State private var shownItem: Item?
  @State private var selection: PageTab = .current
  @State private var layoutGeneration = 0
  @State private var headerHeight: CGFloat = 0

  /// The item whose header shows. It is set when the selection changes, not derived from it, as
  /// `DayBrowser` does for its days.
  @State private var headerItem: Item?

  private var current: Item { shownItem ?? item }
  private var displayedItem: Item { headerItem ?? current }
  private var currentNeighbors: (previous: Item, next: Item) { neighbors(current) }

  @ViewBuilder private func pageView(_ item: Item) -> some View {
    if let digest = digest(item) {
      page(digest, Self.pageDotsClearance)
        // The pages run under the page dots and the tab bar, like the other screens' lists.
        .ignoresSafeArea(.container, edges: .bottom)
    }
  }

  @ViewBuilder private var pager: some View {
    #if os(macOS)
      // There is no swiping here, so there is one page: the current item.
      pageView(current)
    #else
      TabView(selection: $selection) {
        Tab(value: PageTab.previous) {
          pageView(currentNeighbors.previous)
        }
        Tab(value: PageTab.current) {
          pageView(current)
            .onDisappear {
              // Paging away makes the page it arrived at the current one, in the middle again.
              switch selection {
              case .previous: shownItem = currentNeighbors.previous
              case .current: break
              case .next: shownItem = currentNeighbors.next
              }
              selection = .current
            }
        }
        Tab(value: PageTab.next) {
          pageView(currentNeighbors.next)
        }
      }
      // The system page dots, which can be tapped to page, float over the pages.
      .indexViewStyle(.page(backgroundDisplayMode: .always))
      .tabViewStyle(.page(indexDisplayMode: .automatic))
    #endif
  }

  private var pages: some View {
    pager
      #if os(macOS)
        // A scroll view draws its content through a safe area, so the page would scroll over the
        // header. Padding moves the page's edge instead, which clips it, as the paged TabView does.
        .padding(.top, headerHeight + 16)
      #else
        .safeAreaPadding(.top, headerHeight + 16)
      #endif
      // A paged TabView keeps its scroll offset in points, so a width change leaves the page partly
      // scrolled. Rebuild it at the new width; only the current item is ever selected at rest.
      .id(layoutGeneration)
      .onGeometryChange(for: CGFloat.self) {
        $0.size.width
      } action: { oldWidth, newWidth in
        if oldWidth > 0, oldWidth != newWidth {
          layoutGeneration += 1
        }
      }
  }

  var body: some View {
    let displayed = displayedItem
    let displayedDigest = digest(displayed)
    // One header stays behind the pages; its content changes as the pages are paged.
    let displayedNeighbors = neighbors(displayed)
    let neighborDigests = [displayedNeighbors.previous, displayedNeighbors.next]
      .filter { $0 != displayed }.compactMap(digest)
    ZStack(alignment: .top) {
      header(displayed, displayedDigest, neighborDigests)
        .onGeometryChange(for: CGFloat.self) {
          $0.size.height
        } action: {
          headerHeight = $0
        }
      pages
    }
    .onChange(of: selection) {
      switch selection {
      case .previous: headerItem = currentNeighbors.previous
      case .current: headerItem = current
      case .next: headerItem = currentNeighbors.next
      }
    }
    .onChange(of: shownItem) {
      if selection == .current { headerItem = current }
      didShow(current)
    }
    .modifier(MapHeaderStyle(hasMap: true, title: title(displayed, displayedDigest)))
    .toolbar {
      if let displayedDigest {
        ArchiveSharableToolbarContent(item: displayedDigest, url: url(displayedDigest))
      }
    }
  }
}
