//
//  ArtistDetail.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import SwiftUI

struct ArtistDetail: View {
  let digest: ArtistDigest
  let concertCompare: (Concert, Concert) -> Bool
  let isPathNavigable: (PathRestorable) -> Bool

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set")
      Spacer()
      Text(digest.firstSet.rank.formatted())
    }
  }

  @ViewBuilder private var statsElement: some View {
    if !digest.concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        firstSetElement
        StatsGrouping(
          concerts: digest.concerts, shouldCalculateArtistCount: false,
          yearsSpanRanking: digest.spanRank, showRanking: digest.showRank,
          artistVenuesRanking: digest.venueRank,
          weekdaysTitleLocalizedString: "\(digest.name) Weekdays",
          monthsTitleLocalizedString: "\(digest.name) Months")
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.concerts.isEmpty {
      Section(
        header: Text("Shows")
      ) {
        ForEach(digest.concerts.sorted(by: concertCompare)) { concert in
          PathRestorableLink(pathRestorable: concert, isPathNavigable: isPathNavigable) {
            ArtistBlurb(concert: concert)
          }
        }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      Section(
        header: Text("Related Artists")
      ) {
        ForEach(digest.related) { relatedArtist in
          PathRestorableLink(
            pathRestorable: relatedArtist, isPathNavigable: isPathNavigable,
            title: relatedArtist.name)
        }
      }
    }
  }

  var body: some View {
    List {
      statsElement
      showsElement
      relatedsElement
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle(digest.artist.name)
    .toolbar { ArchiveSharableToolbarContent(item: digest) }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistDetail(
    digest: model.vault.artistDigests[0],
    concertCompare: model.vault.comparator.compare(lhs:rhs:),
    isPathNavigable: { _ in
      true
    }
  )
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ArtistDetail(
    digest: model.vault.artistDigests[1],
    concertCompare: model.vault.comparator.compare(lhs:rhs:),
    isPathNavigable: { _ in
      false
    }
  )
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  let selectedConcert = model.vault.artistDigests[1].concerts[0]
  return ArtistDetail(
    digest: model.vault.artistDigests[1],
    concertCompare: model.vault.comparator.compare(lhs:rhs:),
    isPathNavigable: { $0.archivePath != selectedConcert.archivePath }
  )
}
