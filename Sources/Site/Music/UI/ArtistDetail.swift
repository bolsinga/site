//
//  ArtistDetail.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import SwiftUI

struct ArtistDetail: View {
  let digest: ArtistDigest
  let url: URL?
  let isPathNavigable: (ArchivePath) -> Bool

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set")
      Spacer()
      Text(digest.firstSet.rank.formatted())
    }
  }

  @ViewBuilder private var statsElement: some View {
    if !digest.shows.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        firstSetElement
        StatsGrouping(artistDigest: digest)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.shows.isEmpty {
      Section(
        header: Text("Shows")
      ) {
        ForEach(digest.shows.sorted()) { show in
          ArchivePathLink(archivePath: show.id, isPathNavigable: isPathNavigable) {
            ArtistBlurb(count: show.performers.count, venue: show.venue, date: show.date)
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
          ArchivePathLink(
            archivePath: relatedArtist.id, isPathNavigable: isPathNavigable,
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
    .toolbar { ArchiveSharableToolbarContent(item: digest, url: url) }
  }
}

#Preview("All Navigable", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ArtistDetail(
      digest: model.vault.artistDigestMap["ar692"]!,
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
      digest: model.vault.artistDigestMap["ar692"]!,
      url: nil,
      isPathNavigable: { _ in
        false
      }
    )
  }
}

#Preview("First Navigated", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  let digest = model.vault.artistDigestMap["ar692"]!
  let selectedConcert = digest.shows[0]
  NavigationStack {
    ArtistDetail(
      digest: digest,
      url: nil,
      isPathNavigable: { $0 != selectedConcert.id }
    )
  }
}
