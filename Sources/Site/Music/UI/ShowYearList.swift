//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  @Environment(\.vault) private var vault: Vault

  let shows: [Show]

  private var music: Music {
    vault.music
  }

  private var yearPartialDates: [PartialDate] {
    return Array(
      Set(shows.map { $0.date.year != nil ? PartialDate(year: $0.date.year!) : PartialDate() })
    ).sorted(by: <)
  }

  var body: some View {
    List(yearPartialDates, id: \.self) { yearPartialDate in
      NavigationLink(value: yearPartialDate) {
        LabeledContent(
          yearPartialDate.formatted(.yearOnly),
          value: String(
            localized:
              "\(vault.showsForYear(yearPartialDate).count) Show(s)", bundle: .module,
            comment: "Value for the ShowYearList Shows per year."))
      }
    }
    .listStyle(.plain)
    .navigationTitle(Text("Show Years", bundle: .module, comment: "Title for the ShowYearList."))
    .navigationDestination(for: PartialDate.self) {
      ShowList(shows: vault.showsForYear($0), yearPartialDate: $0)
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

    let vault = Vault(music: music)

    NavigationStack {
      ShowYearList(shows: music.shows)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
