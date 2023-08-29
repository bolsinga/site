//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct VenueDetail: View {
  @Environment(\.vault) private var vault: Vault

  let venue: Venue

  private var computedRelatedVenues: [Venue] {
    vault.related(venue).sorted(by: vault.comparator.libraryCompare(lhs:rhs:))
  }

  private var shows: [Show] {
    vault.music.showsForVenue(venue)
  }

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set", bundle: .module, comment: "Venue First Set Caption")
      Spacer()
      Text(vault.lookup.firstSet(venue: venue).rank.formatted())
    }
  }

  @ViewBuilder private var locationElement: some View {
    Section(
      header: Text(
        "Location", bundle: .module,
        comment: "Title of the Location / Address Section for VenueDetail.")
    ) {
      AddressView(location: venue.location)
      LocationMap(location: venue.location)
        .frame(minHeight: 300)
    }
  }

  @ViewBuilder private var statsElement: some View {
    let shows = shows
    Section(header: Text(ArchiveCategory.stats.localizedString)) {
      firstSetElement
      if shows.count > 1 {
        StatsGrouping(
          shows: shows, yearsSpanRanking: vault.lookup.spanRank(venue: venue),
          computeShowsRank: { vault.lookup.venueRank(venue: venue) },
          computeVenueArtistsRank: { vault.lookup.venueArtistRank(venue: venue) })
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    Section(
      header: Text("Shows", bundle: .module, comment: "Title of the Shows section of VenueDetail")
    ) {
      ForEach(shows) { show in
        let concert = vault.lookup.concert(from: show)
        NavigationLink(value: concert) { VenueBlurb(concert: concert) }
      }
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    let relatedVenues = computedRelatedVenues
    if !relatedVenues.isEmpty {
      Section(
        header: Text(
          "Related Venues", bundle: .module,
          comment: "Title of the Related Venues Section for VenueDetail.")
      ) {
        ForEach(relatedVenues) { relatedVenue in
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
    .navigationTitle(venue.name)
    .pathRestorableUserActivityModifier(venue)
    .sharePathRestorable(venue)
  }
}

struct VenueDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData
    NavigationStack {
      VenueDetail(venue: vault.venues[0])
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
