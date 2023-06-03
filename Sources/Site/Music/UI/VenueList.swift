//
//  VenueList.swift
//
//
//  Created by Greg Bolsinga on 4/10/23.
//

import SwiftUI

struct VenueList: View {
  @Environment(\.vault) private var vault: Vault
  let venues: [Venue]

  @Binding var sort: VenueSort

  @State private var searchString: String = ""

  private var sectioner: LibrarySectioner {
    switch sort {
    case .alphabetical:
      return vault.sectioner
    case .showCount:
      return vault.rankSectioner
    case .showYearRange:
      return vault.showSpanSectioner
    case .venueArtistRank:
      return vault.venueArtistRankSectioner
    }
  }

  @ViewBuilder private func contentView(for venue: Venue) -> some View {
    switch sort {
    case .alphabetical, .showYearRange:
      Text("\(vault.lookup.venueRank(venue: venue).value) Show(s)", bundle: .module, comment: "Value for the Artist # of Shows.")
    case .showCount, .venueArtistRank:
      EmptyView()
    }
  }

  @ViewBuilder private func sectionHeader(for section: LibrarySection) -> some View {
    switch sort {
    case .alphabetical:
      section.representingView
    case .showCount:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.showsCountView
      }
    case .showYearRange:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.yearsCountView
      }
    case .venueArtistRank:
      switch section {
      case .alphabetic(_), .numeric, .punctuation:
        EmptyView()
      case .ranking(let ranking):
        ranking.artistsCountView
      }
    }
  }

  var body: some View {
    LibraryComparableList(
      items: venues,
      sectioner: sectioner,
      itemContentView: { contentView(for: $0) },
      sectionHeaderView: { sectionHeader(for: $0) },
      searchString: $searchString
    )
    .navigationTitle(Text("Venues", bundle: .module, comment: "Title for the Venue Detail"))
    .libraryComparableSearchable(
      searchPrompt: String(
        localized: "Venue Names", bundle: .module, comment: "VenueList searchPrompt"),
      searchString: $searchString
    )
    .sortable(algorithm: $sort)
  }
}

struct VenueList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData
    NavigationStack {
      VenueList(venues: vault.music.venues, sort: .constant(.alphabetical))
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
