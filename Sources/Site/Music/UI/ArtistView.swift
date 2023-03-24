//
//  ArtistView.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import SwiftUI

struct ArtistView: View {
  let music: Music
  let artist: Artist

  private var shows: [Show] {
    return music.showsForArtist(artist).sorted(by: music.showCompare(lhs:rhs:))
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(artist.name)
        .font(.title)
      if !shows.isEmpty {
        Divider()
        ForEach(shows, id: \.id) { show in
          ShowBlurbView(music: music, show: show)
        }
      }
    }
  }
}

struct ArtistView_Previews: PreviewProvider {
  static var previews: some View {
    let venue = Venue(
      id: "v10",
      location: Location(
        city: "San Francisco", web: URL(string: "http://www.amoeba.com"), street: "1855 Haight St.",
        state: "CA"), name: "Amoeba Records")

    let artist1 = Artist(id: "ar0", name: "An Artist")

    let artist2 = Artist(id: "ar1", name: "Live Only Band")

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
      artists: [artist1],
      relations: [],
      shows: [show1, show2, show3],
      songs: [],
      timestamp: Date.now,
      venues: [venue])

    ArtistView(music: music, artist: artist1)

    ArtistView(music: music, artist: artist2)
  }
}
