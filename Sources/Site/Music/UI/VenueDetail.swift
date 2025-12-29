//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import MapKit
import SwiftUI

struct VenueDetail: View {
  @Environment(VaultModel.self) private var model

  let digest: VenueDigest
  let isPathNavigable: (ArchivePath) -> Bool

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set")
      Spacer()
      Text(digest.firstSet.rank.formatted())
    }
  }

  @ViewBuilder private var locationElement: some View {
    Section(header: Text("Location")) {
      AddressView(location: digest.venue.location)
      LocationMap(identifier: digest) {
        try await model.geocode(digest.venue)
      }
    }
  }

  @ViewBuilder private var statsElement: some View {
    Section(header: Text(ArchiveCategory.stats.localizedString)) {
      firstSetElement
      if digest.concerts.count > 1 {
        StatsGrouping(venueDigest: digest)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    Section(header: Text("Shows")) {
      ForEach(digest.concerts) { concert in
        ArchivePathLink(archivePath: concert.archivePath, isPathNavigable: isPathNavigable) {
          VenueBlurb(date: concert.show.date, performers: concert.performers)
        }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      Section(header: Text("Related Venues")) {
        ForEach(digest.related) { relatedVenue in
          ArchivePathLink(
            archivePath: relatedVenue.archivePath, isPathNavigable: isPathNavigable,
            title: relatedVenue.name)
        }
      }
    }
  }

  var body: some View {
    List {
      locationElement
      statsElement
      showsElement
      relatedsElement
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle(digest.venue.name)
    .toolbar { ArchiveSharableToolbarContent(item: digest, url: model.vault.url(for: digest)) }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    VenueDetail(
      digest: model.vault.venueDigestMap["v103"]!,
      isPathNavigable: { _ in
        true
      }
    )
  }
}
