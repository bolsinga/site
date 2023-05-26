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
    List(shows) { show in
      NavigationLink(value: show) { TodayBlurb(show: show) }
    }
    .listStyle(.plain)
    .navigationTitle(
      Text(
        "On This Day: \(Date.now.formatted(.dateTime.month(.defaultDigits).day()))",
        bundle: .module, comment: "On This Day: - placeholder is date"))
  }
}

struct TodayList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      TodayList(shows: vault.music.shows)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
