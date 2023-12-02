//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

@preconcurrency import CoreLocation
import MapKit
import SwiftUI

extension CLPlacemark: Identifiable {}

struct VenueDetail: View {
  typealias geocoder = (VenueDigest) async throws -> CLPlacemark

  let digest: VenueDigest
  let concertCompare: (Concert, Concert) -> Bool
  let geocode: geocoder?

  @State private var item: MKMapItem? = nil

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module)
      Spacer()
      Text(digest.firstSet.rank.formatted())
    }
  }

  @MainActor
  @ViewBuilder private var locationElement: some View {
    Section(header: Text("Location", bundle: .module)) {
      AddressView(location: digest.venue.location)
      LocationMap(item: item)
        .task(id: digest) {
          guard let geocode else { return }
          do {
            item = MKMapItem(placemark: MKPlacemark(placemark: try await geocode(digest)))
          } catch {}
        }
        .onTapGesture {
          guard let item else { return }
          item.openInMaps()
        }
        .frame(minHeight: 300)
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
        NavigationLink(value: concert) { VenueBlurb(concert: concert) }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      Section(header: Text("Related Venues", bundle: .module)) {
        ForEach(digest.related) { relatedVenue in
          NavigationLink(relatedVenue.name, value: relatedVenue)
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
    .pathRestorableUserActivityModifier(digest.venue, url: digest.url)
    .sharePathRestorable(digest.venue, url: digest.url)
  }
}

#Preview {
  NavigationStack {
    VenueDetail(
      digest: vaultPreviewData.venueDigests[0],
      concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
      geocode: nil
    )
    .musicDestinations(vaultPreviewData)
  }
}
