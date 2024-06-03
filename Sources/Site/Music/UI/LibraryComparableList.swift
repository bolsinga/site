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

  var body: some View {
    let sectionMap = sectioner.sectionMap(for: filteredItems)
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
    .overlay {
      if !searchString.isEmpty, sectionMap.isEmpty {
        ContentUnavailableView.search(text: searchString)
      }
    }
  }
}

#Preview {
  NavigationStack {
    LibraryComparableList(
      items: vaultPreviewData.artistDigests,
      sectioner: LibrarySectioner(),
      itemContentView: { _ in
        Text(3.formatted(.number))
      },
      sectionHeaderView: { section in
        Text("Artists")
      },
      searchString: .constant("")
    )
    .navigationTitle("Artists")
    .musicDestinations(vaultPreviewData)
  }
}

#Preview {
  NavigationStack {
    LibraryComparableList(
      items: vaultPreviewData.venueDigests,
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
    .musicDestinations(vaultPreviewData)
  }
}
