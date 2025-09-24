//
//  TodayList.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

struct TodayList: View {
  let concerts: [Concert]

  var body: some View {
    if concerts.isEmpty {
      ContentUnavailableView(
        String(localized: "No Shows On This Day"),
        systemImage: "calendar.badge.exclamationmark",
        description: Text("Check again tomorrow.")
      )
      .navigationTitle(Text("On This Day"))
    } else {
      List(concerts) { concert in
        NavigationLink(value: concert) { ConcertBlurb(concert: concert, dateFormat: .relative) }
      }
      .listStyle(.plain)
      .navigationTitle(
        Text(
          "On This Day: \(Date.now.formatted(.dateTime.month(.defaultDigits).day()))"))
    }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  TodayList(concerts: model.vault.concerts.filter { !$0.show.date.isUnknown })
}

#Preview {
  TodayList(concerts: [])
}
