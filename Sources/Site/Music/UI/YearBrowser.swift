//
//  YearBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Shared
import SwiftUI

extension Annum {
  /// The years either side of this one in `annums`, in year order with unknown after the latest
  /// year. The ends wrap: before the oldest year is unknown, and after unknown is the oldest.
  func neighbors(in annums: some Collection<Annum>) -> (previous: Annum, next: Annum) {
    let ordered = Set(annums).union([self]).sorted()
    guard let index = ordered.firstIndex(of: self) else { return (self, self) }
    let previous = ordered[(index + ordered.count - 1) % ordered.count]
    let next = ordered[(index + 1) % ordered.count]
    return (previous, next)
  }
}

/// A year's details that can be paged to the previous and next year, like the Today pager.
struct YearBrowser: View {
  let annum: Annum
  let annums: [Annum]
  let digest: (Annum) -> AnnumDigest?
  let url: (AnnumDigest) -> URL?
  let isPathNavigable: (ArchivePath) -> Bool
  /// Called with the year the pager settles on, so the navigation path names the year shown.
  let didShowAnnum: (Annum) -> Void

  /// How far above the bottom of the pages the system page dots reach, which a page leaves clear
  /// under its last card, as `DayBrowser` does.
  private static let pageDotsClearance: CGFloat = 44

  enum YearTab: Int {
    case previous
    case current
    case next
  }

  @State private var shownAnnum: Annum?
  @State private var selection: YearTab = .current
  @State private var layoutGeneration = 0
  @State private var mapHeight: CGFloat = 0

  /// The year whose shows the map shows. It is set when the selection changes, not derived from
  /// it, as `DayBrowser` does for its days.
  @State private var mapAnnum: Annum?

  private var current: Annum { shownAnnum ?? annum }
  private var displayedAnnum: Annum { mapAnnum ?? current }
  private var neighbors: (previous: Annum, next: Annum) { current.neighbors(in: annums) }

  @ViewBuilder private func page(_ annum: Annum) -> some View {
    if let digest = digest(annum) {
      YearDetail(
        digest: digest, url: url(digest), isPathNavigable: isPathNavigable,
        bottomContentMargin: Self.pageDotsClearance
      )
      // The pages run under the page dots and the tab bar, like the other screens' lists.
      .ignoresSafeArea(.container, edges: .bottom)
    }
  }

  @ViewBuilder private var pager: some View {
    #if os(macOS)
      // There is no swiping here, so there is one page: the current year.
      page(current)
    #else
      TabView(selection: $selection) {
        Tab(value: YearTab.previous) {
          page(neighbors.previous)
        }
        Tab(value: YearTab.current) {
          page(current)
            .onDisappear {
              // Paging away makes the page it arrived at the current one, in the middle again.
              switch selection {
              case .previous: shownAnnum = neighbors.previous
              case .current: break
              case .next: shownAnnum = neighbors.next
              }
              selection = .current
            }
        }
        Tab(value: YearTab.next) {
          page(neighbors.next)
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
        // map. Padding moves the page's edge instead, which clips it, as the paged TabView does.
        .padding(.top, mapHeight + 16)
      #else
        .safeAreaPadding(.top, mapHeight + 16)
      #endif
      // A paged TabView keeps its scroll offset in points, so a width change leaves the page partly
      // scrolled. Rebuild it at the new width; only the current year is ever selected at rest.
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
    let displayed = displayedAnnum
    let displayedDigest = digest(displayed)
    // One map stays behind the pages; its shows change as the pages are paged.
    ZStack(alignment: .top) {
      ShowsMapHeader(
        shows: displayedDigest?.shows ?? [], title: displayed.formatted(), animatesChanges: true
      )
      .onGeometryChange(for: CGFloat.self) {
        $0.size.height
      } action: {
        mapHeight = $0
      }
      pages
    }
    .onChange(of: selection) {
      switch selection {
      case .previous: mapAnnum = neighbors.previous
      case .current: mapAnnum = current
      case .next: mapAnnum = neighbors.next
      }
    }
    .onChange(of: shownAnnum) {
      if selection == .current { mapAnnum = current }
      didShowAnnum(current)
    }
    .modifier(MapHeaderStyle(hasMap: true, title: displayed.formatted()))
    .toolbar {
      if let displayedDigest {
        ArchiveSharableToolbarContent(item: displayedDigest, url: url(displayedDigest))
      }
    }
  }
}
