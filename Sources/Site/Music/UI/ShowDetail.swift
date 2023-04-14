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

  private var music: Music {
    vault.music
  }

  private var artists: [Artist] {
    do {
      return try music.artistsForShow(show)
    } catch {
      return []
    }
  }

  private var venueName: String {
    do {
      return try music.venueForShow(show).name
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
    LabeledContent(
      String(
        localized: "Date", bundle: .module, comment: "Title of the data section of ShowDetail"),
      value: show.date.formatted(.compact))
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
  }
}

struct ShowDetail_Previews: PreviewProvider {
  static var previews: some View {
    let artist1 = Artist(id: "ar0", name: "Artist With Longer Name")
    let artist2 = Artist(id: "ar1", name: "Artist 2")

    let venue = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")

    let show1 = Show(
      artists: [artist1.id, artist2.id], comment: "The show was Great!",
      date: PartialDate(year: 2001, month: 1, day: 15), id: "sh15", venue: venue.id)

    let show2 = Show(
      artists: [artist1.id, artist2.id], comment: "The show was Great!",
      date: PartialDate(year: 2010, month: 1), id: "sh16", venue: venue.id)

    let show3 = Show(
      artists: [artist1.id],
      date: PartialDate(), id: "sh17", venue: venue.id)

    let music = Music(
      albums: [],
      artists: [artist1, artist2],
      relations: [],
      shows: [show1, show2, show3],
      songs: [],
      timestamp: Date.now,
      venues: [venue])

    let vault = Vault(music: music)

    NavigationStack {
      ShowDetail(show: show1)
        .environment(\.vault, vault)
        .musicDestinations()
    }

    NavigationStack {
      ShowDetail(show: show2)
        .environment(\.vault, vault)
        .musicDestinations()
    }

    NavigationStack {
      ShowDetail(show: show3)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
