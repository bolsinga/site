//
//  ShowDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct ShowDetail: View {
  let concert: Concert
  let isPathNavigable: (ArchivePath) -> Bool

  private var venueName: String {
    guard let venue = concert.venue else {
      return ""
    }
    return venue.name
  }

  private var date: PartialDate { concert.show.date }
  private var comment: String? { concert.show.comment }

  @ViewBuilder private var lineupElement: some View {
    Section(header: Text("Lineup")) {
      ForEach(concert.artists) { artist in
        ArchivePathLink(
          archivePath: artist.archivePath, isPathNavigable: isPathNavigable, title: artist.name)
      }
    }
  }

  @ViewBuilder private var dateElement: some View {
    Section(header: Text("Date")) {
      let showDate = date
      if !showDate.isUnknown, let date = showDate.date {
        LabeledContent {
          Text(date.formatted(.relative(presentation: .numeric)))
        } label: {
          Text(showDate.formatted(.compact))
        }
      } else {
        Text(showDate.formatted(.compact))
      }
    }
  }

  @ViewBuilder private var commentElement: some View {
    if let comment {
      Section(header: Text("Comment")) {
        Text(comment.asAttributedString)
      }
    }
  }

  var body: some View {
    List {
      lineupElement
      dateElement
      commentElement
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle(venueName)
    .toolbar { ArchiveSharableToolbarContent(item: concert) }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ShowDetail(
      concert: model.vault.concertMap["sh899"]!,
      isPathNavigable: { _ in
        true
      }
    )
  }
}
