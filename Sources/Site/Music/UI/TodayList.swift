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
      Section {
        List(concerts) { concert in
          NavigationLink(value: concert) { TodayBlurb(concert: concert) }
        }
        .listStyle(.plain)
      } header: {
        Text(
          "On This Day: \(Date.now.formatted(.dateTime.month(.defaultDigits).day()))",
          bundle: .module
        )
        .font(.title)
      }
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  TodayList(concerts: model.vault.concerts.filter { !$0.show.date.isUnknown })
}

#Preview {
  TodayList(concerts: [])
}
