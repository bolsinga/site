//
//  DayList.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

struct DayList: View {
  fileprivate let concerts: [ShowDigest]
  let dayOfLeapYear: Int

  internal init(concerts: [ShowDigest], dayOfLeapYear: Int) {
    self.concerts = concerts
    self.dayOfLeapYear = dayOfLeapYear
  }

  private var isToday: Bool { dayOfLeapYear.isToday }

  var body: some View {
    Group {
      if concerts.isEmpty {
        ContentUnavailableView(
          isToday ? String(localized: "No Shows Today") : String(localized: "No Shows"),
          systemImage: "calendar.badge.exclamationmark",
          description: isToday ? Text("Check again tomorrow.") : nil
        )
      } else {
        List(concerts) { concert in
          NavigationLink(value: concert.archivePath) {
            ConcertBlurb(
              venue: concert.venue,
              date: concert.date,
              performers: concert.performerNames,
              dateFormat: .relative)
          }
        }
        .listStyle(.plain)
      }
    }
    .navigationTitle(dayOfLeapYear.relativeTitle)
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
