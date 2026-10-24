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

  internal init(concerts: [ShowDigest], dayOfLeapYear: Int, hasMapHeader: Bool = true) {
    self.concerts = concerts
    self.dayOfLeapYear = dayOfLeapYear
    self.hasMapHeader = hasMapHeader
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
            FirstTimesCard(shows: concerts)
              .padding(.horizontal)
            DetailCard(title: Text("Shows")) {
              ForEach(concerts) { concert in
                NavigationLink(value: concert.archivePath) {
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
