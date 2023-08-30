//
//  ArtistDetail.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import SwiftUI

struct ArtistDetail: View {
  @Environment(\.vault) private var vault: Vault

  let artist: Artist
  let concerts: [Concert]

  private var computedRelatedArtists: [Artist] {
    vault.related(artist).sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
  }

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module, comment: "First Set Caption")
      Spacer()
      Text(vault.lookup.firstSet(artist: artist).rank.formatted())
    }
  }

  @ViewBuilder private var statsElement: some View {
    if !concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        firstSetElement
        StatsGrouping(
          concerts: concerts, shouldCalculateArtistCount: false,
          yearsSpanRanking: vault.lookup.spanRank(artist: artist),
          computeShowsRank: { vault.lookup.showRank(artist: artist) },
          computeArtistVenuesRank: { vault.lookup.artistVenueRank(artist: artist) })
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !concerts.isEmpty {
      Section(
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of ArtistDetail")
      ) {
        ForEach(concerts) { concert in
          NavigationLink(value: concert) { ArtistBlurb(concert: concert) }
        }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    let relatedArtists = computedRelatedArtists
    if !relatedArtists.isEmpty {
      Section(
        header: Text(
          "Related Artists", bundle: .module,
          comment: "Title of the Related Artists Section for ArtistDetail.")
      ) {
        ForEach(relatedArtists) { relatedArtist in
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
    .navigationTitle(artist.name)
    .pathRestorableUserActivityModifier(artist)
    .sharePathRestorable(artist)
  }
}

struct ArtistDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      let artist = vault.artists[0]
      ArtistDetail(
        artist: artist, concerts: vault.concerts.filter { $0.show.artists.contains(artist.id) }
      )
      .environment(\.vault, vault)
      .musicDestinations()
    }

    NavigationStack {
      let artist = vault.artists[1]
      ArtistDetail(
        artist: artist, concerts: vault.concerts.filter { $0.show.artists.contains(artist.id) }
      )
      .environment(\.vault, vault)
      .musicDestinations()
    }
  }
}
