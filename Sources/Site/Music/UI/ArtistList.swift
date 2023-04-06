//
//  ArtistList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ArtistList: View {
  let artists: [Artist]

  @State private var searchString: String = ""

  private var filteredArtists: [Artist] {
    guard !searchString.isEmpty else { return artists }
    return artists.filter { $0.name.lowercased().contains(searchString.lowercased()) }
  }

  private var filteredSections: [String] {
    return Set(filteredArtists.map { librarySection($0) }).sorted()
  }

  private func filteredArtists(for section: String) -> [Artist] {
    return filteredArtists.filter { librarySection($0) == section }
  }

  var body: some View {
    List {
      ForEach(filteredSections, id: \.self) { section in
        Section(section) {
          ForEach(filteredArtists(for: section)) { artist in
            NavigationLink(artist.name, value: artist)
          }
        }
      }
    }
    .listStyle(.plain)
    .searchable(text: $searchString)
    .navigationTitle(Text("Artists", bundle: .module, comment: "Title for the Artist Detail"))
  }
}

struct ArtistList_Previews: PreviewProvider {
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
      artists: [artist1, artist2],
      relations: [],
      shows: [show1, show2, show3],
      songs: [],
      timestamp: Date.now,
      venues: [venue])

    NavigationStack {
      ArtistList(artists: music.artists)
        .environment(\.music, music)
    }
  }
}
