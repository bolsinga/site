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
  let isPathActive: (PathRestorable) -> Bool

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module)
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
          yearsSpanRanking: digest.spanRank,
          computeShowsRank: { digest.showRank },
          computeArtistVenuesRank: { digest.venueRank })
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.concerts.isEmpty {
      Section(
        header: Text("Shows", bundle: .module)
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
        header: Text("Related Artists", bundle: .module)
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
    .pathRestorableUserActivityModifier(digest, url: digest.url, isPathActive: isPathActive)
    .archiveShare(digest.artist, url: digest.url)
  }
}

#Preview {
  NavigationStack {
    ArtistDetail(
      digest: vaultPreviewData.artistDigests[0],
      concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
      isPathNavigable: { _ in
        true
      },
      isPathActive: { _ in
        true
      }
    )
    .musicDestinations(vaultPreviewData)
  }
}

#Preview {
  NavigationStack {
    ArtistDetail(
      digest: vaultPreviewData.artistDigests[1],
      concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
      isPathNavigable: { _ in
        true
      },
      isPathActive: { _ in
        true
      }
    )
    .musicDestinations(vaultPreviewData)
  }
}

#Preview {
  let selectedConcert = vaultPreviewData.artistDigests[1].concerts[0]
  return NavigationStack {
    ArtistDetail(
      digest: vaultPreviewData.artistDigests[1],
      concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
      isPathNavigable: { $0.archivePath != selectedConcert.archivePath },
      isPathActive: { _ in
        true
      }
    )
    .musicDestinations(vaultPreviewData, path: [selectedConcert.archivePath])
  }
}
