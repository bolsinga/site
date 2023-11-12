//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList: View {
  let venueDigests: [VenueDigest]
  let nearbyVenueIDs: Set<Venue.ID>
  let sectioner: LibrarySectioner

  @Binding var sort: VenueSort
  @Binding var locationFilter: LocationFilter
  @Binding var geocodingProgress: Double
  @Binding var locationAuthorization: LocationAuthorization

  @State private var searchString: String = ""

  private var filteredVenueDigests: [VenueDigest] {
    switch locationFilter {
    case .none:
      return venueDigests
    case .nearby:
      return venueDigests.filter { nearbyVenueIDs.contains($0.id) }
    }
  }

  private func rank(for venueDigest: VenueDigest) -> Ranking {
    switch sort {
    case .alphabetical, .firstSeen:
      return Ranking.empty
    case .showCount:
      return venueDigest.showRank
    case .showYearRange:
      return venueDigest.spanRank
    case .venueArtistRank:
      return venueDigest.venueArtistRank
    }
  }

  @ViewBuilder private func showCount(for venueDigest: VenueDigest) -> some View {
    Text("\(venueDigest.showRank.value) Show(s)", bundle: .module)
  }

  @ViewBuilder private func sectionHeader(for ranking: Ranking) -> some View {
    switch sort {
    case .alphabetical, .firstSeen:
      EmptyView()
    case .showCount:
      ranking.showsCountView
    case .showYearRange:
      ranking.yearsCountView
    case .venueArtistRank:
      ranking.artistsCountView
    }
  }

  @ViewBuilder private var listElement: some View {
    let venueDigests = filteredVenueDigests
    if case .alphabetical = sort {
      LibraryComparableList(
        items: venueDigests,
        sectioner: sectioner,
        itemContentView: { showCount(for: $0) },
        sectionHeaderView: { $0.representingView },
        searchString: $searchString
      )
    } else if case .firstSeen = sort {
      RankingList(
        items: venueDigests,
        rankingMapBuilder: {
          $0.reduce(into: [PartialDate: [(VenueDigest, FirstSet)]]()) {
            let firstSet = $1.firstSet
            var arr = ($0[firstSet.date] ?? [])
            arr.append(($1, firstSet))
            $0[firstSet.date] = arr
          }.reduce(into: [PartialDate: [VenueDigest]]()) {
            $0[$1.key] = $1.value.sorted(by: { lhs, rhs in
              lhs.1.rank < rhs.1.rank
            }).map { $0.0 }
          }
        },
        rankSorted: PartialDate.compareWithUnknownsMuted(lhs:rhs:),
        itemContentView: {
          Text($0.firstSet.rank.formatted(.hash))
        },
        sectionHeaderView: {
          Text($0.formatted(.compact))
        },
        searchString: $searchString)
    } else {
      RankingList(
        items: venueDigests,
        rankingMapBuilder: {
          $0.reduce(into: [Ranking: [VenueDigest]]()) {
            let ranking = rank(for: $1)
            var arr = ($0[ranking] ?? [])
            arr.append($1)
            $0[ranking] = arr
          }
        },
        itemContentView: {
          if case .showYearRange = sort {
            showCount(for: $0)
          }
        },
        sectionHeaderView: { sectionHeader(for: $0) },
        searchString: $searchString)
    }
  }

  var body: some View {
    listElement
      .navigationTitle(Text("Venues", bundle: .module))
      .searchable(
        text: $searchString,
        prompt: String(localized: "Venue Names", bundle: .module)
      )
      .sortable(algorithm: $sort)
      .locationFilter(
        $locationFilter, geocodingProgress: $geocodingProgress,
        locationAuthorization: $locationAuthorization,
        filteredDataIsEmpty: filteredVenueDigests.isEmpty)
  }
}

#Preview {
  NavigationStack {
    VenueList(
      venueDigests: vaultPreviewData.venueDigests,
      nearbyVenueIDs: Set(vaultPreviewData.venueDigests.map { $0.id }),
      sectioner: vaultPreviewData.sectioner, sort: .constant(.alphabetical),
      locationFilter: .constant(.none), geocodingProgress: .constant(0),
      locationAuthorization: .constant(.allowed)
    )
    .musicDestinations(vaultPreviewData)
  }
}
