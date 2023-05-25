//
//  LibraryComparableList.swift
//
//
//  Created by Greg Bolsinga on 4/4/23.
//

import SwiftUI

struct LibraryComparableList<T>: View
where T: LibraryComparable, T: Identifiable, T: Hashable, T.ID == String {
  @Environment(\.vault) private var vault: Vault

  let items: [T]
  let searchPrompt: String
  let itemContentValue: (T) -> Int

  @State private var searchString: String = ""
  @Binding var algorithm: LibrarySectionAlgorithm

  private var filteredItems: [T] {
    guard !searchString.isEmpty else { return items }
    return items.filter { $0.name.lowercased().contains(searchString.lowercased()) }
  }

  private var sectionMap: [LibrarySection: [T]] {
    filteredItems.reduce(into: [LibrarySection: [T]]()) {
      let section = vault.sectioner(for: algorithm).librarySection($1)
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
                algorithm.itemContentView(itemContentValue(item))
              } label: {
                Text(item.name)
              }
            }
          }
        } header: {
          algorithm.headerView(section)
        }
      }
    }
    .listStyle(.plain)
    .searchable(text: $searchString, prompt: searchPrompt)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Picker(selection: $algorithm) {
          ForEach(LibrarySectionAlgorithm.allCases, id: \.self) { category in
            Text(category.localizedString).tag(category)
          }
        } label: {
          Text(
            "Sort Order", bundle: .module,
            comment: "Shown to change the sort order of the LibraryComparableList.")
        }
      }
    }
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
        itemContentValue: {
          vault.music.showsForArtist($0).count
        }, algorithm: .constant(.alphabetical)
      )
      .navigationTitle("Artists")
      .environment(\.vault, vault)
      .musicDestinations()
    }

    NavigationStack {
      LibraryComparableList(
        items: music.venues,
        searchPrompt: "Venue Names",
        itemContentValue: { _ in
          0
        }, algorithm: .constant(.alphabetical)
      )
      .navigationTitle("Venues")
      .environment(\.vault, vault)
      .musicDestinations()
    }
  }
}
