//
//  ShowList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowList: View {
  let shows: [Show]
  var yearPartialDate: PartialDate?

  private var title: String {
    if let yearPartialDate {
      return String(
        localized: "\(yearPartialDate.formatted(.yearOnly)) Shows",
        bundle: .module,
        comment: "Title for the ShowList when there is a year")
    }
    return String(
      localized: "Shows",
      bundle: .module,
      comment: "Title for the ShowList")
  }

  var body: some View {
    List(shows) { show in
      NavigationLink(archivable: show) { ShowBlurb(show: show) }
    }
    .listStyle(.plain)
    .navigationTitle(Text(title))
  }
}

struct ShowList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ShowList(shows: vault.music.shows)
        .environment(\.vault, vault)
        .archiveDestinations()
    }
  }
}
