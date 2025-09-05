//
//  ShowDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import MusicData
import SwiftUI

struct ShowDetail: View {
  let concert: Concert
  let isPathNavigable: (PathRestorable) -> Bool

  private var venueName: String {
    guard let venue = concert.venue else {
      return ""
    }
    return venue.name
  }

  @ViewBuilder private var lineupElement: some View {
    Section(header: Text("Lineup", bundle: .module)) {
      ForEach(concert.artists) { artist in
        PathRestorableLink(
          pathRestorable: artist, isPathNavigable: isPathNavigable, title: artist.name)
      }
    }
  }

  @ViewBuilder private var dateElement: some View {
    Section(header: Text("Date", bundle: .module)) {
      let show = concert.show
      if !show.date.isUnknown, let date = show.date.date {
        LabeledContent {
          Text(date.formatted(.relative(presentation: .numeric)))
        } label: {
          Text(show.date.formatted(.compact))
        }
      } else {
        Text(show.date.formatted(.compact))
      }
    }
  }

  @ViewBuilder private var commentElement: some View {
    if let comment = concert.show.comment {
      Section(header: Text("Comment", bundle: .module)) {
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

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ShowDetail(
    concert: model.vault.concerts[0],
    isPathNavigable: { _ in
      true
    }
  )
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ShowDetail(
    concert: model.vault.concerts[1],
    isPathNavigable: { _ in
      true
    }
  )
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ShowDetail(
    concert: model.vault.concerts[2],
    isPathNavigable: { _ in
      true
    }
  )
}
