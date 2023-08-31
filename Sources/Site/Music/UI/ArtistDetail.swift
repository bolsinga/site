//
//  ArtistDetail.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import SwiftUI

struct ArtistDetail: View {
  @Environment(\.vault) private var vault: Vault

  let digest: ArtistDigest

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module, comment: "First Set Caption")
      Spacer()
      Text(vault.lookup.firstSet(artist: digest.artist).rank.formatted())
    }
  }

  @ViewBuilder private var statsElement: some View {
    if !digest.concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        firstSetElement
        StatsGrouping(
          concerts: digest.concerts, shouldCalculateArtistCount: false,
          yearsSpanRanking: vault.lookup.spanRank(artist: digest.artist),
          computeShowsRank: { vault.lookup.showRank(artist: digest.artist) },
          computeArtistVenuesRank: { vault.lookup.artistVenueRank(artist: digest.artist) })
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.concerts.isEmpty {
      Section(
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of ArtistDetail")
      ) {
        ForEach(digest.concerts) { concert in
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
    let vault = Vault.previewData

    NavigationStack {
      ArtistDetail(digest: vault.digest(for: vault.artists[0]))
        .environment(\.vault, vault)
        .musicDestinations()
    }

    NavigationStack {
      ArtistDetail(digest: vault.digest(for: vault.artists[1]))
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
