//
//  ShowDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Shared
import SwiftUI

struct ShowDetail: View {
  let concert: ShowDigest
  let url: URL?
  let isPathNavigable: (ArchivePath) -> Bool

  private var venueName: String {
    concert.venue
  }

  private var date: PartialDate { concert.date }
  private var comment: String? { concert.comment }

  @ViewBuilder private var lineupElement: some View {
    DetailCard(title: Text("Lineup")) {
      ForEach(concert.performers) { artist in
        ArchivePathLink(archivePath: artist.id, isPathNavigable: isPathNavigable) {
          DetailRowLabel(isNavigable: isPathNavigable(artist.id)) {
            Text(artist.name)
          }
        }
        if artist.id != concert.performers.last?.id {
          Divider()
        }
      }
      .buttonStyle(.plain)
    }
  }

  /// The date leads the page, with how long ago (or until) the show is beneath it.
  @ViewBuilder private var dateElement: some View {
    VStack(alignment: .leading) {
      Text(date.formatted(.compact))
        .font(.largeTitle.bold())
      if !date.isUnknown, let showDate = date.date {
        Text(showDate.formatted(.relative(presentation: .numeric)))
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder private var commentElement: some View {
    if let comment {
      DetailCard(title: Text("Comment")) {
        Text(comment.asAttributedString)
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        dateElement
        lineupElement
        commentElement
      }
      .padding(.horizontal)
    }
    .background(.background)
    .navigationTitle(venueName)
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
    .toolbar { ArchiveSharableToolbarContent(item: concert, url: url) }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ShowDetail(
      concert: model.previewShow("sh899"),
      url: nil,
      isPathNavigable: { _ in
        true
      }
    )
  }
}
