//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct VenueDetail: View {
  @Environment(\.vault) private var vault: Vault

  let digest: VenueDigest

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module, comment: "Venue First Set Caption")
      Spacer()
      Text(digest.firstSet.rank.formatted())
    }
  }

  @ViewBuilder private var locationElement: some View {
    Section(
      header: Text(
        "Location", bundle: .module,
        comment: "Title of the Location / Address Section for VenueDetail.")
    ) {
      AddressView(location: digest.venue.location)
      LocationMap(location: digest.venue.location) {
        try await vault.atlas.geocode($0)
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
    Section(
      header: Text("Shows", bundle: .module, comment: "Title of the Shows section of VenueDetail")
    ) {
      ForEach(digest.concerts) { concert in
        NavigationLink(value: concert) { VenueBlurb(concert: concert) }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      Section(
        header: Text(
          "Related Venues", bundle: .module,
          comment: "Title of the Related Venues Section for VenueDetail.")
      ) {
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

struct VenueDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData
    NavigationStack {
      VenueDetail(digest: vault.digest(for: vault.venues[0]))
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
