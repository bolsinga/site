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

  private var hasMap: Bool { !digest.shows.isEmpty }

  @ViewBuilder private var headerElement: some View {
    if hasMap {
      ShowsMapHeader(shows: digest.shows, title: digest.annum.formatted())
    }
  }

  @ViewBuilder private var statsElement: some View {
    if !digest.shows.isEmpty {
      StatsCard(stats: Stats(annumDigest: digest), titles: StatsTitles(annum: digest.annum))
    }
  }

  @ViewBuilder private var showsElement: some View {
    if !digest.shows.isEmpty {
      DetailCard(title: Text("Shows")) {
        let shows = digest.shows.sorted()
        ForEach(shows) { show in
          ArchivePathLink(archivePath: show.id, isPathNavigable: isPathNavigable) {
            DetailRowLabel(isNavigable: isPathNavigable(show.id)) {
              ConcertBlurb(
                venue: show.venue,
                date: show.date,
                performers: show.performerNames,
                dateFormat: .noYear)
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
        headerElement
        VStack(spacing: 16) {
          statsElement
          showsElement
        }
        .padding(.horizontal)
      }
    }
    // A ScrollView is transparent, so the view beneath can show through.
    .background(.background)
    .modifier(MapHeaderStyle(hasMap: hasMap, title: digest.annum.formatted()))
    .toolbar { ArchiveSharableToolbarContent(item: digest, url: url) }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    YearDetail(
      digest: model.previewAnnum(.year(2001)),
      url: nil,
      isPathNavigable: { _ in
        true
      }
    )
  }
}
