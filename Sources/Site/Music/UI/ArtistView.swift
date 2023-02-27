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

  var body: some View {
    VStack(alignment: .leading) {
      Text(artist.name)
        .font(.title)
      Divider()
      ForEach(albums, id: \.id) { album in
        HStack {
          Text(album.formattedTitle)
        }
      }
    }
  }
}

struct ArtistView_Previews: PreviewProvider {
  static var previews: some View {
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

    let music = Music(
      albums: [album1, album2, album3],
      artists: [artist1],
      relations: [],
      shows: [],
      songs: [],
      timestamp: Date.now,
      venues: [])

    ArtistView(music: music, artist: artist1)
  }
}
