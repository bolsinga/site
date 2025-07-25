//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import MapKit
import SwiftUI

private enum VenueDetailGeocodeError: Error {
  case noGeocoder
}

struct VenueDetail: View {
  typealias geocoder = @MainActor (VenueDigest) async throws -> MKMapItem

  let digest: VenueDigest
  let concertCompare: (Concert, Concert) -> Bool
  let geocode: geocoder?
  let isPathNavigable: (PathRestorable) -> Bool

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module)
      Spacer()
      Text(digest.firstSet.rank.formatted())
    }
  }

  @ViewBuilder private var locationElement: some View {
    Section(header: Text("Location", bundle: .module)) {
      AddressView(location: digest.venue.location)
      LocationMap(identifier: digest) {
        guard let geocode else {
          throw VenueDetailGeocodeError.noGeocoder
        }
        return try await geocode(digest)
      }
    }
  }

  @ViewBuilder private var statsElement: some View {
    Section(header: Text(ArchiveCategory.stats.localizedString)) {
      firstSetElement
      if digest.concerts.count > 1 {
        StatsGrouping(
          concerts: digest.concerts, yearsSpanRanking: digest.spanRank,
          computeShowsRank: { digest.showRank },
          computeVenueArtistsRank: { digest.venueArtistRank })
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    Section(header: Text("Shows", bundle: .module)) {
      ForEach(digest.concerts.sorted(by: concertCompare)) { concert in
        PathRestorableLink(pathRestorable: concert, isPathNavigable: isPathNavigable) {
          VenueBlurb(concert: concert)
        }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      Section(header: Text("Related Venues", bundle: .module)) {
        ForEach(digest.related) { relatedVenue in
          PathRestorableLink(
            pathRestorable: relatedVenue, isPathNavigable: isPathNavigable, title: relatedVenue.name
          )
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
    .toolbar { ArchiveSharableToolbarContent(item: digest) }
  }
}

#Preview("Error") {
  VenueDetail(
    digest: vaultPreviewData.venueDigests[0],
    concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
    geocode: nil,
    isPathNavigable: { _ in
      true
    }
  )
}

#Preview("Current Location after 10 seconds") {
  VenueDetail(
    digest: vaultPreviewData.venueDigests[0],
    concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
    geocode: { _ in
      try await ContinuousClock().sleep(until: .now + Duration.seconds(10))
      return MKMapItem.forCurrentLocation()
    },
    isPathNavigable: { _ in
      true
    }
  )
}
