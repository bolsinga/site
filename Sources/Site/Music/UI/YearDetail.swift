//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct YearDetail: View {
  @Environment(\.vault) private var vault: Vault
  let annum: Annum
  let shows: [Show]

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
          NavigationLink(value: show) { ConcertBlurb(concert: vault.concert(from: show)) }
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
    .navigationTitle(Text(annum.formatted()))
    .pathRestorableUserActivityModifier(annum)
    .sharePathRestorable(annum)
  }
}

struct YearDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      let annum = Annum.year(2001)
      YearDetail(annum: annum, shows: vault.lookup.decadesMap[annum.decade]?[annum] ?? [])
        .musicDestinations()
    }
  }
}
