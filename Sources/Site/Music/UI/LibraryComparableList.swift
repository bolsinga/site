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
  let itemContentValue: (T) -> Int

  @Binding var searchString: String
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
    let vault = Vault.previewData

    NavigationStack {
      LibraryComparableList(
        items: vault.music.artists, itemContentValue: { vault.music.showsForArtist($0).count },
        searchString: .constant(""), algorithm: .constant(.alphabetical)
      )
      .navigationTitle("Artists")
      .environment(\.vault, vault)
      .musicDestinations()
    }

    NavigationStack {
      LibraryComparableList(
        items: vault.music.venues, itemContentValue: { _ in 0 }, searchString: .constant(""),
        algorithm: .constant(.alphabetical)
      )
      .navigationTitle("Venues")
      .environment(\.vault, vault)
      .musicDestinations()
    }
  }
}
