//
//  ArtistDetail.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import Shared
import SwiftUI

struct ArtistDetail: View {
  let digest: ArtistDigest
  let isPathNavigable: (ArchivePath) -> Bool
  /// Room left under the last card for something floating over the bottom of the page.
  var bottomContentMargin: CGFloat = 0

  @ViewBuilder private var statsElement: some View {
    if !digest.shows.isEmpty {
      StatsCard(
        stats: Stats(artistDigest: digest), titles: StatsTitles(artistDigest: digest),
        firstSetRank: digest.rank.firstSet.rank)
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.shows.isEmpty {
      DetailCard(title: Text("Shows")) {
        let shows = digest.shows.sorted()
        ForEach(shows) { show in
          ArchivePathLink(archivePath: show.id, isPathNavigable: isPathNavigable) {
            DetailRowLabel(isNavigable: isPathNavigable(show.id)) {
              ArtistBlurb(
                count: show.performers.count, venue: show.venue,
                isFirstTimeVenue: show.isFirstTimeVenue, isMostRecentVenue: show.isMostRecentVenue,
                date: show.date)
            }
          }
          if show.id != shows.last?.id {
            Divider()
          }
        }
        .buttonStyle(.plain)
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      DetailCard(title: Text("Related Artists")) {
        ForEach(digest.related) { relatedArtist in
          ArchivePathLink(archivePath: relatedArtist.id, isPathNavigable: isPathNavigable) {
            DetailRowLabel(isNavigable: isPathNavigable(relatedArtist.id)) {
              Text(relatedArtist.name)
            }
          }
          if relatedArtist.id != digest.related.last?.id {
            Divider()
          }
        }
        .buttonStyle(.plain)
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        statsElement
        showsElement
        relatedsElement
      }
      .padding(.horizontal)
    }
    // A pager keeps this page when it pages to another artist, with the offset of the artist it
    // came from. A scroll view for each artist starts at the top, as the page it paged from did.
    .id(digest.id)
    .contentMargins(.bottom, bottomContentMargin, for: .scrollContent)
  }
}

#Preview("All Navigable", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ArtistBrowser(
      id: .artist("ar692"), artistIDs: model.vault.orderedArtistIDs,
      digest: { model.vault.digest(artist: $0) }, url: { _ in nil }, isPathNavigable: { _ in true },
      didShow: { _ in })
  }
}

#Preview("None Navigable", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ArtistBrowser(
      id: .artist("ar692"), artistIDs: model.vault.orderedArtistIDs,
      digest: { model.vault.digest(artist: $0) }, url: { _ in nil },
      isPathNavigable: { _ in false }, didShow: { _ in })
  }
}

#Preview("First Navigated", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  let selectedConcert = model.previewArtist("ar692").shows[0]
  NavigationStack {
    ArtistBrowser(
      id: .artist("ar692"), artistIDs: model.vault.orderedArtistIDs,
      digest: { model.vault.digest(artist: $0) }, url: { _ in nil },
      isPathNavigable: { $0 != selectedConcert.id }, didShow: { _ in })
  }
}
