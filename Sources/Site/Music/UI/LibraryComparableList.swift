//
//  LibraryComparableList.swift
//
//
//  Created by Greg Bolsinga on 4/4/23.
//

import SwiftUI

struct LibraryComparableList<T, ItemContent: View, SectionHeader: View>: View
where T: LibraryComparable, T: Identifiable, T: Hashable, T.ID == String, T: PathRestorable {
  let items: [T]
  let sectioner: LibrarySectioner
  let itemContentView: (T) -> ItemContent
  let sectionHeaderView: (LibrarySection) -> SectionHeader

  @Binding var searchString: String

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
        if let items = sectionMap[section] {
          Section {
            ForEach(items) { item in
              NavigationLink(value: item) {
                LabeledContent {
                  itemContentView(item)
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
    }
    .listStyle(.plain)
  }
}

struct LibraryComparableList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      LibraryComparableList(
        items: vault.artists,
        sectioner: LibrarySectioner(),
        itemContentView: {
          Text(vault.music.showsForArtist($0).count.formatted(.number))
        },
        sectionHeaderView: { section in
          Text("Artists")
        },
        searchString: .constant("")
      )
      .navigationTitle("Artists")
      .environment(\.vault, vault)
      .musicDestinations()
    }

    NavigationStack {
      LibraryComparableList(
        items: vault.venues,
        sectioner: LibrarySectioner(),
        itemContentView: { _ in
          EmptyView()
        },
        sectionHeaderView: { section in
          Text("Venues")
        },
        searchString: .constant("")
      )
      .navigationTitle("Venues")
      .environment(\.vault, vault)
      .musicDestinations()
    }
  }
}
