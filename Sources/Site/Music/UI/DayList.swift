//
//  DayList.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

extension Date {
  fileprivate var isToday: Bool {
    self.dayMonth == Date.now.dayMonth
  }
}

struct DayList: View {
  let concerts: [Concert]
  let date: Date  // TODO: Make this a DayMonth. Add a formatter for DayMonth for the title, and isToday property. Alternately have this be the only property and it references the model.

  var body: some View {
    Group {
      if concerts.isEmpty {
        ContentUnavailableView(
          date.isToday ? String(localized: "No Shows Today") : String(localized: "No Shows"),
          systemImage: "calendar.badge.exclamationmark",
          description: date.isToday ? Text("Check again tomorrow.") : nil
        )
      } else {
        List(concerts) { concert in
          NavigationLink(value: concert) { ConcertBlurb(concert: concert, dateFormat: .relative) }
        }
        .listStyle(.plain)
      }
    }
    .navigationTitle(
      Text(
        "On This Day: \(date.formatted(.dateTime.month(.defaultDigits).day()))"))
  }
}

#Preview("Concerts Today", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    DayList(concerts: model.vault.concertsToday, date: .now)
  }
}

#Preview("Empty Concerts Today") {
  NavigationStack {
    DayList(concerts: [], date: .now)
  }
}

#Preview("Empty Concerts Not Today") {
  NavigationStack {
    DayList(concerts: [], date: .now.addingTimeInterval(24 * 60 * 60))
  }
}
