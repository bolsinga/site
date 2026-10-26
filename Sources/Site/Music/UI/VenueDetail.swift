//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Shared
import SwiftUI

struct VenueDetail: View {
  let digest: VenueDigest
  let isPathNavigable: (ArchivePath) -> Bool
  /// Room left under the last card for something floating over the bottom of the page.
  var bottomContentMargin: CGFloat = 0

  @ViewBuilder private var statsElement: some View {
    StatsCard(
      stats: Stats(venueDigest: digest), titles: StatsTitles(venueDigest: digest),
      firstSetRank: digest.rank.firstSet.rank, includesCategories: digest.shows.count > 1)
  }

  @ViewBuilder private var showsElement: some View {
    DetailCard(title: Text("Shows")) {
      let shows = digest.shows.sorted()
      ForEach(shows) { show in
        ArchivePathLink(archivePath: show.id, isPathNavigable: isPathNavigable) {
          DetailRowLabel(isNavigable: isPathNavigable(show.id)) {
            VenueBlurb(
              date: show.date, performers: show.performers,
              firstTimeArtistIDs: show.firstTimeArtistIDs,
              mostRecentArtistIDs: show.mostRecentArtistIDs)
          }
        }
        if show.id != shows.last?.id {
          Divider()
        }
      }
      .buttonStyle(.plain)
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      DetailCard(title: Text("Related Venues")) {
        ForEach(digest.related) { relatedVenue in
          ArchivePathLink(archivePath: relatedVenue.id, isPathNavigable: isPathNavigable) {
            DetailRowLabel(isNavigable: isPathNavigable(relatedVenue.id)) {
              Text(relatedVenue.name)
            }
          }
          if relatedVenue.id != digest.related.last?.id {
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
    // A pager keeps this page when it pages to another venue, with the offset of the venue it
    // came from. A scroll view for each venue starts at the top, as the page it paged from did.
    .id(digest.id)
    .contentMargins(.bottom, bottomContentMargin, for: .scrollContent)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    VenueBrowser(
      id: .venue("v103"), venueIDs: model.vault.orderedVenueIDs,
      digest: { model.vault.digest(venue: $0) }, url: { _ in nil }, isPathNavigable: { _ in true },
      didShow: { _ in })
  }
}
