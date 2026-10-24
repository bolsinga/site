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
  let url: URL?
  let isPathNavigable: (ArchivePath) -> Bool

  @ViewBuilder private var headerElement: some View {
    if hasMap {
      ShowsMapHeader(shows: digest.shows, title: digest.name)
    }
  }

  private var hasMap: Bool { !digest.shows.isEmpty }

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
        headerElement
        VStack(spacing: 16) {
          statsElement
          showsElement
          relatedsElement
        }
        .padding(.horizontal)
      }
    }
    // A ScrollView is transparent, so the view beneath can show through.
    .background(.background)
    .modifier(MapHeaderStyle(hasMap: hasMap, title: digest.name))
    .toolbar { ArchiveSharableToolbarContent(item: digest, url: url) }
  }
}

#Preview("All Navigable", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ArtistDetail(
      digest: model.previewArtist("ar692"),
      url: nil,
      isPathNavigable: { _ in
        true
      }
    )
  }
}

#Preview("None Navigable", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ArtistDetail(
      digest: model.previewArtist("ar692"),
      url: nil,
      isPathNavigable: { _ in
        false
      }
    )
  }
}

#Preview("First Navigated", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  let digest = model.previewArtist("ar692")
  let selectedConcert = digest.shows[0]
  NavigationStack {
    ArtistDetail(
      digest: digest,
      url: nil,
      isPathNavigable: { $0 != selectedConcert.id }
    )
  }
}
