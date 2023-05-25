//
//  LibraryComparableList.swift
//
//
//  Created by Greg Bolsinga on 4/4/23.
//

import SwiftUI

struct LibraryComparableList<T, ItemContent: View, SectionContent : View>: View
where T: LibraryComparable, T: Identifiable, T: Hashable, T.ID == String {

  let items: [T]
  let searchPrompt: String
  let sectioner: LibrarySectioner
  @ViewBuilder let itemContentView: (T) -> ItemContent
  @ViewBuilder let headerView: ((LibrarySection) -> SectionContent)

  @State private var searchString: String = ""

  private var filteredItems: [T] {
    guard !searchString.isEmpty else { return items }
    return items.filter { $0.name.lowercased().contains(searchString.lowercased()) }
  }

  private var sectionMap: [LibrarySection: [T]] {
    filteredItems.reduce(into: [LibrarySection: [T]]()) {
      let section = sectioner.librarySection($1)
      var arr = ($0[section] ?? [])
      arr.append($1)
      $0[section] = arr
    }
  }

  var body: some View {
    let sectionMap = sectionMap
    List {
      ForEach(sectionMap.keys.sorted(), id: \.self) { section in
        Section {
          ForEach(sectionMap[section] ?? []) { item in
            NavigationLink(value: item) {
              LabeledContent {
                itemContentView(item)
              } label: {
                Text(item.name)
              }
            }
          }
        } header: {
          headerView(section)
        }
      }
    }
    .listStyle(.plain)
    .searchable(text: $searchString, prompt: searchPrompt)
  }
}

struct LibraryComparableList_Previews: PreviewProvider {
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

    let vault = Vault(music: music)

    NavigationStack {
      LibraryComparableList(
        items: music.artists,
        searchPrompt: "Artist Names",
        sectioner: vault.sectioner,
        itemContentView: { (artist: Artist) in
          Text(vault.music.showsForArtist(artist).count.formatted(.number))
        },
        headerView: { section in
          section.representingView
        }
      )
      .navigationTitle("Artists")
      .environment(\.vault, vault)
      .musicDestinations()
    }

    NavigationStack {
      LibraryComparableList(
        items: music.venues,
        searchPrompt: "Venue Names",
        sectioner: vault.sectioner,
        itemContentView: { _ in
        },
        headerView: { section in
          section.representingView
        }
      )
      .navigationTitle("Venues")
      .environment(\.vault, vault)
      .musicDestinations()
    }
  }
}
