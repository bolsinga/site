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

  internal init(concerts: [ShowDigest], dayOfLeapYear: Int) {
    self.concerts = concerts
    self.dayOfLeapYear = dayOfLeapYear
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
