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
      Text(
        "No Shows On This Day", bundle: .module,
        comment: "Text shown when there are no shows today."
      )
      .font(.title)
      .foregroundColor(.secondary)
    } else {
      List(concerts) { concert in
        NavigationLink(value: concert) { TodayBlurb(concert: concert) }
      }
      .listStyle(.plain)
      .navigationTitle(
        Text(
          "On This Day: \(Date.now.formatted(.dateTime.month(.defaultDigits).day()))",
          bundle: .module, comment: "On This Day: - placeholder is date"))
    }
  }
}

struct TodayList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      TodayList(concerts: vault.concerts)
        .musicDestinations()
    }
  }
}
