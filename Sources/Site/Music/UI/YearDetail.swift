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

  private var concerts: [Concert] {
    digest.concerts
  }

  @ViewBuilder private var statsElement: some View {
    let concerts = concerts
    if !concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(
          concerts: concerts,
          shouldCalculateArtistCount: true,
          showRanking: digest.showRank,
          artistVenuesRanking: digest.venueRank,
          venueArtistsRanking: digest.artistRank,
          weekdaysTitleLocalizedString: "\(digest.annum.formatted(.year)) Weekdays",
          monthsTitleLocalizedString: "\(digest.annum.formatted(.year)) Months",
          alwaysShowVenuesArtistsStats: true)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    let concerts = concerts
    if !concerts.isEmpty {
      Section(header: Text("Shows")) {
        ForEach(concerts.sorted(by: concertCompare)) { concert in
          PathRestorableLink(pathRestorable: concert, isPathNavigable: isPathNavigable) {
            ConcertBlurb(concert: concert, dateFormat: .noYear)
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

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  YearDetail(
    digest: model.vault.annumDigestMap[.year(2001)]!,
    concertCompare: model.vault.comparator.compare(lhs:rhs:),
    isPathNavigable: { _ in
      true
    }
  )
}
