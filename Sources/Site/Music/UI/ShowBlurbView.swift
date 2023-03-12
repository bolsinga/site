//
//  ShowBlurbView.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import SwiftUI

struct ShowBlurbView: View {
  let music: Music
  let show: Show

  private var venue: Venue? {
    do {
      return try music.venueForShow(show)
    } catch {
      return nil
    }
  }

  var body: some View {
    HStack(alignment: .bottom) {
      if let venue {
        Text(venue.name)
          .font(.headline)
      }
      Text(PartialDate.FormatStyle().format(show.date))
        .font(.caption)
    }
    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
  }
}

struct ShowBlurbView_Previews: PreviewProvider {
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

    ShowBlurbView(music: music, show: show1)

    ShowBlurbView(music: music, show: show2)

    ShowBlurbView(music: music, show: show3)
  }
}