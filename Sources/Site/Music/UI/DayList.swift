//
//  DayList.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

struct DayList: View {
  fileprivate let concerts: [Concert]
  let dayOfLeapYear: Int

  internal init(concerts: [Concert], dayOfLeapYear: Int) {
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
          NavigationLink(value: concert) { ConcertBlurb(concert: concert, dateFormat: .relative) }
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
    DayList(concerts: model.vault.concertsToday, dayOfLeapYear: Date.now.dayOfLeapYear)
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
