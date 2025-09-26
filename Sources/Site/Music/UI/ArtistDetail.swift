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
        StatsGrouping(stats: Stats(artistDigest: digest))
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

#Preview("All Navigable", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ArtistDetail(
      digest: model.vault.artistDigestMap["ar692"]!,
      concertCompare: model.vault.comparator.compare(lhs:rhs:),
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
      concertCompare: model.vault.comparator.compare(lhs:rhs:),
      isPathNavigable: { _ in
        false
      }
    )
  }
}

#Preview("First Navigated", traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  let digest = model.vault.artistDigestMap["ar692"]!
  let selectedConcert = digest.concerts[0]
  NavigationStack {
    ArtistDetail(
      digest: digest,
      concertCompare: model.vault.comparator.compare(lhs:rhs:),
      isPathNavigable: { $0.archivePath != selectedConcert.archivePath }
    )
  }
}
