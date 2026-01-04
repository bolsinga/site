//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct YearDetail: View {
  let digest: AnnumDigest
  let url: URL?
  let isPathNavigable: (ArchivePath) -> Bool

  @ViewBuilder private var statsElement: some View {
    if !digest.shows.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(annumDigest: digest)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.shows.isEmpty {
      Section(header: Text("Shows")) {
        ForEach(digest.shows) { show in
          ArchivePathLink(archivePath: show.id, isPathNavigable: isPathNavigable) {
            ConcertBlurb(
              venue: show.venue, date: show.date, performers: show.performers, dateFormat: .noYear)
          }
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
    .toolbar { ArchiveSharableToolbarContent(item: digest, url: url) }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    YearDetail(
      digest: model.vault.annumDigestMap[.year(2001)]!,
      url: nil,
      isPathNavigable: { _ in
        true
      }
    )
  }
}
