//
//  ArtistView.swift
//
//
//  Created by Greg Bolsinga on 2/18/23.
//

import SwiftUI

extension Album {
  var formattedTitle: String {
    var parts = [String]()
    parts.append(title)
    if let release {
      parts.append("(\(Music.description(for: release)))")
    }
    return parts.joined(separator: " ")
  }
}

struct ArtistView: View {
  let music: Music
  let artist: Artist

  private var albums: [Album] {
    do {
      return try music.albumsForArtist(artist).sorted(by: music.albumCompare(lhs:rhs:))
    } catch {
      return []
    }
  }

  private var shows: [Show] {
    return music.showsForArtist(artist).sorted(by: music.showCompare(lhs:rhs:))
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(artist.name)
        .font(.title)
      if !albums.isEmpty {
        Divider()
        ForEach(albums, id: \.id) { album in
          HStack {
            Text(album.formattedTitle)
              .padding(2)
          }
        }
      }
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

    let album1 = Album(
      id: "a1",
      performer: "ar0",
      release: PartialDate(year: 1970),
      songs: [],
      title: "Another Title")

    let album2 = Album(
      id: "a0",
      performer: "ar0",
      release: PartialDate(year: 1970),
      songs: [],
      title: "Album Title")

    let album3 = Album(
      id: "a2",
      performer: "ar0",
      songs: [],
      title: "Unknown Title")

    let artist1 = Artist(albums: [album1.id, album2.id, album3.id], id: "ar0", name: "An Artist")

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
      albums: [album1, album2, album3],
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
