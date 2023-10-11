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

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module, comment: "First Set Caption")
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
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of ArtistDetail")
      ) {
        ForEach(digest.concerts.sorted(by: concertCompare)) { concert in
          NavigationLink(value: concert) { ArtistBlurb(concert: concert) }
        }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      Section(
        header: Text(
          "Related Artists", bundle: .module,
          comment: "Title of the Related Artists Section for ArtistDetail.")
      ) {
        ForEach(digest.related) { relatedArtist in
          NavigationLink(relatedArtist.name, value: relatedArtist)
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
    .pathRestorableUserActivityModifier(digest.artist, url: digest.url)
    .sharePathRestorable(digest.artist, url: digest.url)
  }
}

struct ArtistDetail_Previews: PreviewProvider {
  static var previews: some View {

    NavigationStack {
      ArtistDetail(
        digest: vaultPreviewData.artistDigests[0],
        concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:)
      )
      .musicDestinations(vaultPreviewData)
    }

    NavigationStack {
      ArtistDetail(
        digest: vaultPreviewData.artistDigests[1],
        concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:)
      )
      .musicDestinations(vaultPreviewData)
    }
  }
}
