//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import Shared
import SwiftUI

struct YearDetail: View {
  let digest: AnnumDigest
  let url: URL?
  let isPathNavigable: (ArchivePath) -> Bool
  /// Room left under the last card for something floating over the bottom of the page.
  var bottomContentMargin: CGFloat = 0

  @ViewBuilder private var statsElement: some View {
    if !digest.shows.isEmpty {
      StatsCard(
        stats: Stats(annumDigest: digest), titles: StatsTitles(annum: digest.annum),
        rankKind: .annum)
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.shows.isEmpty {
      DetailCard(title: Text("Shows")) {
        let shows = digest.shows.sorted()
        ForEach(shows) { show in
          ArchivePathLink(archivePath: show.id, isPathNavigable: isPathNavigable) {
            DetailRowLabel(isNavigable: isPathNavigable(show.id)) {
              ConcertBlurb(digest: show, dateFormat: .noYear)
            }
          }
          if show.id != shows.last?.id {
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
      }
      .padding(.horizontal)
    }
    // A pager keeps this page when it pages to another year, with the offset of the year it
    // came from. A scroll view for each year starts at the top, as the page it paged from did.
    .id(digest.annum)
    .contentMargins(.bottom, bottomContentMargin, for: .scrollContent)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    YearBrowser(
      annum: .year(2001), annums: [.year(2000), .year(2001), .year(2002)],
      digest: { model.previewAnnum($0) }, url: { _ in nil }, isPathNavigable: { _ in true },
      didShowAnnum: { _ in })
  }
}
