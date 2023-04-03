//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  @Environment(\.music) private var music: Music

  let shows: [Show]

  private var yearsOfShows: [Int] {
    return Array(Set(shows.map { $0.date.normalizedYear })).sorted(by: <)
  }

  var body: some View {
    VStack {
      List(yearsOfShows, id: \.self) { year in
        NavigationLink(String(year), value: year)
      }
      .listStyle(.plain)
      .navigationTitle(Text("Show Years", bundle: .module, comment: "Title for the ShowYearList."))
      .navigationDestination(for: Int.self) { year in
        ShowList(shows: music.showsForYear(year), year: year)
      }
      Divider()
      Text(
        "\(yearsOfShows.count) Year(s)", bundle: .module,
        comment:
          "Years count shown at the bottom of the ShowYearList."
      )
    }
  }
}

struct ShowYearList_Previews: PreviewProvider {
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

    NavigationStack {
      ShowYearList(shows: music.shows)
        .environment(\.music, music)
    }
  }
}
