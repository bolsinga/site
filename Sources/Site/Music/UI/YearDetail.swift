//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct YearDetail: View {
  let shows: [Show]
  var yearPartialDate: PartialDate?

  private var title: String {
    if let yearPartialDate {
      return String(
        localized: "\(yearPartialDate.formatted(.yearOnly)) Shows",
        bundle: .module,
        comment: "Title for the YearDetail when there is a year")
    }
    return String(
      localized: "Shows",
      bundle: .module,
      comment: "Title for the YearDetail")
  }

  var body: some View {
    List(shows) { show in
      NavigationLink(value: show) { ShowBlurb(show: show) }
    }
    .listStyle(.plain)
    .navigationTitle(Text(title))
  }
}

struct YearDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      YearDetail(shows: vault.music.shows)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
