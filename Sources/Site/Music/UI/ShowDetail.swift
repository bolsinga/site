//
//  ShowDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct ShowDetail: View {
  @Environment(\.vault) private var vault: Vault
  let show: Show

  private var artists: [Artist] {
    do {
      return try vault.lookup.artistsForShow(show)
    } catch {
      return []
    }
  }

  private var venueName: String {
    do {
      return try vault.lookup.venueForShow(show).name
    } catch {
      return ""
    }
  }

  @ViewBuilder private var lineupElement: some View {
    Section(
      header: Text(
        "Lineup", bundle: .module,
        comment: "Title of the Lineup for ShowDetail.")
    ) {
      ForEach(artists) { artist in
        NavigationLink(artist.name, value: artist)
      }
    }
  }

  @ViewBuilder private var dateElement: some View {
    Section(
      header: Text("Date", bundle: .module, comment: "Title of the date section of ShowDetail")
    ) {
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
    if let comment = show.comment {
      Section(
        header: Text(
          "Comment", bundle: .module, comment: "Title of the comment section of ShowDetail")
      ) {
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
    .userActivity(ArchivePath.activityType) { show.updateActivity($0) }
  }
}

struct ShowDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ShowDetail(show: vault.music.shows[0])
        .environment(\.vault, vault)
        .musicDestinations()
    }

    NavigationStack {
      ShowDetail(show: vault.music.shows[1])
        .environment(\.vault, vault)
        .musicDestinations()
    }

    NavigationStack {
      ShowDetail(show: vault.music.shows[2])
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
