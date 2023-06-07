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
      return yearPartialDate.formatted(.yearOnly)
    }
    return String(
      localized: "Shows",
      bundle: .module,
      comment: "Title for the YearDetail")
  }

  @ViewBuilder private var statsElement: some View {
    if !shows.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(shows: shows)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !shows.isEmpty {
      Section(
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of YearDetail")
      ) {
        ForEach(shows) { show in
          NavigationLink(archivable: show) { ShowBlurb(show: show) }
        }
      }
    }
  }

  var body: some View {
    List {
      statsElement
      showsElement
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle(Text(title))
  }
}

struct YearDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      YearDetail(shows: vault.music.shows)
        .environment(\.vault, vault)
        .archiveDestinations()
    }
  }
}
