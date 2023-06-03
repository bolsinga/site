//
//  LibraryComparableList.swift
//
//
//  Created by Greg Bolsinga on 4/4/23.
//

import SwiftUI

struct LibraryComparableList<T, SectionHeader: View>: View
where T: LibraryComparable, T: Identifiable, T: Hashable, T.ID == String {
  @Environment(\.vault) private var vault: Vault

  let items: [T]
  let itemContentValue: (T) -> Int
  let sectioner: LibrarySectioner
  let sectionHeaderView: (LibrarySection) -> SectionHeader

  @Binding var searchString: String
  @Binding var algorithm: LibrarySectionAlgorithm

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
                algorithm.itemContentView(itemContentValue(item))
              } label: {
                Text(item.name)
              }
            }
          }
        } header: {
          sectionHeaderView(section)
        }
      }
    }
    .listStyle(.plain)
  }
}

struct LibraryComparableList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      LibraryComparableList(
        items: vault.music.artists,
        itemContentValue: { vault.music.showsForArtist($0).count },
        sectioner: LibrarySectioner(),
        sectionHeaderView: { section in
          Text("Artists")
        },
        searchString: .constant(""),
        algorithm: .constant(.alphabetical)
      )
      .navigationTitle("Artists")
      .environment(\.vault, vault)
      .musicDestinations()
    }

    NavigationStack {
      LibraryComparableList(
        items: vault.music.venues,
        itemContentValue: { _ in 0 },
        sectioner: LibrarySectioner(),
        sectionHeaderView: { section in
          Text("Venues")
        },
        searchString: .constant(""),
        algorithm: .constant(.alphabetical)
      )
      .navigationTitle("Venues")
      .environment(\.vault, vault)
      .musicDestinations()
    }
  }
}
