//
//  DayBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct DayBrowser: View {
  @Environment(VaultModel.self) var model

  enum DayTab: Int {
    case yesterday
    case today
    case tomorrow
  }

  @Binding var dayOfLeapYear: Int
  @State private var selection: DayTab = .today
  @State private var layoutGeneration = 0
  @State private var mapHeight: CGFloat = 0

  /// The day whose shows the map shows. It is set when the selection changes, not derived from
  /// it: paging to a day moves `dayOfLeapYear` and resets `selection` as separate steps, and
  /// deriving the day from both would show a wrong day, and its venues, in between.
  @State private var mapDayOfLeapYear: Int?

  private var displayedDayOfLeapYear: Int { mapDayOfLeapYear ?? dayOfLeapYear }

  @ViewBuilder private func dayList(_ dayOfLeapYear: Int) -> some View {
    DayList(
      concerts: model.concerts(on: dayOfLeapYear), dayOfLeapYear: dayOfLeapYear,
      hasMapHeader: false)
  }

  private var pages: some View {
    TabView(selection: $selection) {
      Tab(value: DayTab.yesterday) {
        dayList(dayOfLeapYear.previousDayOfLeapYear)
      }

      Tab(value: DayTab.today) {
        dayList(dayOfLeapYear)
          .onDisappear {
            switch selection {
            case .yesterday:
              dayOfLeapYear = dayOfLeapYear.previousDayOfLeapYear
            case .today:
              break
            case .tomorrow:
              dayOfLeapYear = dayOfLeapYear.nextDayOfLeapYear
            }

            selection = .today
          }
      }

      Tab(value: DayTab.tomorrow) {
        dayList(dayOfLeapYear.nextDayOfLeapYear)
      }
    }
    #if !os(macOS)
      .indexViewStyle(.page(backgroundDisplayMode: .always))
      .tabViewStyle(.page(indexDisplayMode: .automatic))
    #endif
    // The pages start below the map, and scroll over it.
    .safeAreaPadding(.top, mapHeight + 16)
    // A paged TabView keeps its scroll offset in points, so a width change (folding, rotating,
    // resizing) leaves the page partly scrolled and the list shifted sideways. Rebuild it at the
    // new width; only today is ever selected at rest, so nothing is lost.
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
    let day = displayedDayOfLeapYear
    let title = String(localized: day.relativeTitle)
    // One map stays behind the pages; its shows change as the pages are paged.
    ZStack(alignment: .top) {
      ShowsMapHeader(shows: model.concerts(on: day), title: title, animatesChanges: true)
        .onGeometryChange(for: CGFloat.self) {
          $0.size.height
        } action: {
          mapHeight = $0
        }
      pages
    }
    .onChange(of: selection) {
      switch selection {
      case .yesterday:
        mapDayOfLeapYear = dayOfLeapYear.previousDayOfLeapYear
      case .today:
        mapDayOfLeapYear = dayOfLeapYear
      case .tomorrow:
        mapDayOfLeapYear = dayOfLeapYear.nextDayOfLeapYear
      }
    }
    .onChange(of: dayOfLeapYear) {
      if selection == .today { mapDayOfLeapYear = dayOfLeapYear }
    }
    .modifier(MapHeaderStyle(hasMap: true, title: title))  // need this here for ipad
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @State var dayOfLeapYear = Date.now.dayOfLeapYear

  NavigationStack {
    DayBrowser(dayOfLeapYear: $dayOfLeapYear)
  }
}
