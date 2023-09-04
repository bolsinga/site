//
//  ShowDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import SwiftUI

struct ShowDetail: View {
  let concert: Concert

  private var venueName: String {
    guard let venue = concert.venue else {
      return ""
    }
    return venue.name
  }

  @ViewBuilder private var lineupElement: some View {
    Section(
      header: Text(
        "Lineup", bundle: .module,
        comment: "Title of the Lineup for ShowDetail.")
    ) {
      ForEach(concert.artists) { artist in
        NavigationLink(artist.name, value: artist)
      }
    }
  }

  @ViewBuilder private var dateElement: some View {
    Section(
      header: Text("Date", bundle: .module, comment: "Title of the date section of ShowDetail")
    ) {
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
    .pathRestorableUserActivityModifier(concert, url: concert.url)
    .sharePathRestorable(concert, url: concert.url)
  }
}

struct ShowDetail_Previews: PreviewProvider {
  static var previews: some View {
    let vaultPreview = Vault.previewData

    NavigationStack {
      ShowDetail(concert: vaultPreview.concerts[0])
        .musicDestinations(vaultPreview)
    }

    NavigationStack {
      ShowDetail(concert: vaultPreview.concerts[1])
        .musicDestinations(vaultPreview)
    }

    NavigationStack {
      ShowDetail(concert: vaultPreview.concerts[2])
        .musicDestinations(vaultPreview)
    }
  }
}
