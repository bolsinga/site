//
//  TodayList.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

struct TodayList: View {
  let shows: [Show]

  var body: some View {
    if shows.isEmpty {
      Text(
        "No Shows On This Day", bundle: .module,
        comment: "Text shown when there are no shows today."
      )
      .font(.title)
      .foregroundColor(.secondary)
    } else {
      List(shows) { show in
        NavigationLink(archivable: show) { TodayBlurb(show: show) }
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
      TodayList(shows: vault.music.shows)
        .environment(\.vault, vault)
        .archiveDestinations()
    }
  }
}
