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

  private var music: Music {
    vault.music
  }

  private var computedShows: [Show] {
    return music.showsForArtist(artist).sorted {
      vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }
  }

  private var computedRelatedArtists: [Artist] {
    music.related(artist).sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
  }

  @ViewBuilder private var statsElement: some View {
    let shows = computedShows
    if !shows.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(
          shows: shows, kind: .artist, yearsSpanRanking: vault.lookup.spanRank(artist: artist),
          computeShowsRank: { vault.lookup.showRank(artist: artist) })
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    let shows = computedShows
    if !shows.isEmpty {
      Section(
        header: Text(
          "Shows", bundle: .module, comment: "Title of the Shows section of ArtistDetail")
      ) {
        ForEach(shows) { show in
          NavigationLink(value: show) {
            ArtistBlurb(show: show)
          }
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
  }
}

struct ArtistDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ArtistDetail(artist: vault.music.artists[0])
        .environment(\.vault, vault)
        .musicDestinations()
    }

    NavigationStack {
      ArtistDetail(artist: vault.music.artists[1])
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
