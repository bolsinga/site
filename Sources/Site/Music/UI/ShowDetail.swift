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

  @ViewBuilder private var venueElement: some View {
    DetailCard(title: Text("Venue")) {
      ArchivePathLink(archivePath: concert.venueID, isPathNavigable: isPathNavigable) {
        DetailRowLabel(isNavigable: isPathNavigable(concert.venueID)) {
          VStack(alignment: .leading) {
            Text(venueName)
              .font(.title2.bold())
            Text("\(concert.location.city), \(concert.location.state)")
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .buttonStyle(.plain)
    }
  }

  /// The date leads the page, with how long ago (or until) the show is at the trailing edge.
  @ViewBuilder private var dateElement: some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
      Text(date.formatted(.compact))
        .font(.largeTitle.bold())
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      Spacer(minLength: 0)
      if !date.isUnknown, let showDate = date.date {
        Text(showDate.formatted(.relative(presentation: .numeric)))
          .font(.subheadline.weight(.semibold))
          .textCase(.uppercase)
          .foregroundStyle(.secondary)
          .lineLimit(1)
          .minimumScaleFactor(0.5)
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
        venueElement
        lineupElement
        commentElement
      }
      .padding(.horizontal)
    }
    .background(.background)
    .navigationTitle(concert.formatted(.headlinerAndVenue))  // Hidden below, but still titles the back button.
    #if !os(tvOS)
      .toolbar(removing: .title)
    #endif
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
