//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct YearDetail: View {
  let annum: Annum
  let url: URL?
  let concerts: [Concert]

  @ViewBuilder private var statsElement: some View {
    if !concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(concerts: concerts)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !concerts.isEmpty {
      Section(
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of YearDetail")
      ) {
        ForEach(concerts) { concert in
          NavigationLink(value: concert) { ConcertBlurb(concert: concert) }
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
    .pathRestorableUserActivityModifier(annum, url: url)
    .sharePathRestorable(annum, url: url)
  }
}

struct YearDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      let annum = Annum.year(2001)
      YearDetail(
        annum: annum, url: vault.createURL(for: annum.archivePath),
        concerts: vault.concerts(during: annum)
      )
      .musicDestinations()
    }
  }
}
