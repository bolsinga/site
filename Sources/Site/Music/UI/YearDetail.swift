//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct YearDetail: View {
  let digest: AnnumDigest
  let concertCompare: (Concert, Concert) -> Bool
  let isPathNavigable: (PathRestorable) -> Bool

  @ViewBuilder private var statsElement: some View {
    if !digest.concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(annumDigest: digest)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.concerts.isEmpty {
      Section(header: Text("Shows")) {
        ForEach(digest.concerts.sorted(by: concertCompare)) { concert in
          PathRestorableLink(pathRestorable: concert, isPathNavigable: isPathNavigable) {
            ConcertBlurb(
              venue: concert.venue?.name, date: concert.show.date, performers: concert.performers,
              dateFormat: .noYear)
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
    .toolbar { ArchiveSharableToolbarContent(item: digest) }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    YearDetail(
      digest: model.vault.annumDigestMap[.year(2001)]!,
      concertCompare: model.vault.comparator.compare(lhs:rhs:),
      isPathNavigable: { _ in
        true
      }
    )
  }
}
