//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct YearDetail: View {
  let digest: AnnumDigest

  @ViewBuilder private var statsElement: some View {
    if !digest.concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(concerts: digest.concerts)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.concerts.isEmpty {
      Section(
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of YearDetail")
      ) {
        ForEach(digest.concerts) { concert in
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
    .navigationTitle(Text(digest.annum.formatted()))
    .pathRestorableUserActivityModifier(digest.annum, url: digest.url)
    .sharePathRestorable(digest.annum, url: digest.url)
  }
}

struct YearDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      YearDetail(digest: vault.digest(for: Annum.year(2001)))
        .musicDestinations()
    }
  }
}
