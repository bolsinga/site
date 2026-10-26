//
//  DayList.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import Shared
import SwiftUI

struct DayList: View {
  fileprivate let concerts: [ShowDigest]
  let dayOfLeapYear: Int
  /// Whether the list shows its own map. A container showing one map for several days leaves it out.
  fileprivate let hasMapHeader: Bool
  /// Room left under the last row for something floating over the bottom of the list.
  fileprivate let bottomContentMargin: CGFloat

  internal init(
    concerts: [ShowDigest], dayOfLeapYear: Int, hasMapHeader: Bool = true,
    bottomContentMargin: CGFloat = 0
  ) {
    self.concerts = concerts
    self.dayOfLeapYear = dayOfLeapYear
    self.hasMapHeader = hasMapHeader
    self.bottomContentMargin = bottomContentMargin
  }

  var body: some View {
    Group {
      if concerts.isEmpty {
        let message = NoShowsMessage(dayOfLeapYear: dayOfLeapYear)
        ContentUnavailableView(
          message.title, systemImage: message.systemImage,
          description: message.description.map(Text.init)
        )
      } else {
        ScrollView {
          VStack(spacing: 16) {
            if hasMapHeader {
              ShowsMapHeader(shows: concerts, title: String(localized: dayOfLeapYear.relativeTitle))
            }
            StatsCard(stats: Stats(dayShows: concerts), titles: .generic)
              .padding(.horizontal)
            DetailCard(title: Text("Shows")) {
              ForEach(concerts) { concert in
                NavigationLink(value: concert.id) {
                  DetailRowLabel(isNavigable: true) {
                    ConcertBlurb(digest: concert, dateFormat: .relative)
                  }
                }
                if concert.id != concerts.last?.id {
                  Divider()
                }
              }
              .buttonStyle(.plain)
            }
            .padding(.horizontal)
          }
        }
        // A pager keeps this list when it pages to another day, with the offset of the day it
        // came from. A list for each day starts at the top, as the page it paged from did.
        .id(dayOfLeapYear)
        .contentMargins(.bottom, bottomContentMargin, for: .scrollContent)
        .background(hasMapHeader ? AnyShapeStyle(.background) : AnyShapeStyle(.clear))
      }
    }
    .modifier(
      MapHeaderStyle(
        hasMap: !concerts.isEmpty, title: String(localized: dayOfLeapYear.relativeTitle),
        isApplied: hasMapHeader))
  }
}

#Preview("Concerts Today", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    let dayOfLeapYear = Date.now.dayOfLeapYear
    DayList(concerts: model.concerts(on: dayOfLeapYear), dayOfLeapYear: dayOfLeapYear)
  }
}

#Preview("Empty Concerts Today") {
  NavigationStack {
    DayList(concerts: [], dayOfLeapYear: Date.now.dayOfLeapYear)
  }
}

#Preview("Empty Concerts Not Today") {
  NavigationStack {
    DayList(concerts: [], dayOfLeapYear: Date.now.dayOfLeapYear + 1)
  }
}
