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
        String(localized: "No Shows On This Day", bundle: .module),
        systemImage: "calendar.badge.exclamationmark",
        description: Text("Check again tomorrow.", bundle: .module)
      )
    } else {
      List(concerts) { concert in
        NavigationLink(value: concert) { TodayBlurb(concert: concert) }
      }
      .listStyle(.plain)
      .navigationTitle(
        Text(
          "On This Day: \(Date.now.formatted(.dateTime.month(.defaultDigits).day()))",
          bundle: .module))
    }
  }
}

#Preview {
  NavigationStack {
    TodayList(concerts: vaultPreviewData.concerts)
      .musicDestinations(vaultPreviewData)
  }
}

#Preview {
  NavigationStack {
    TodayList(concerts: [])
      .musicDestinations(vaultPreviewData)
  }
}
