//
//  RankingList.swift
//
//
//  Created by Greg Bolsinga on 6/3/23.
//

import SwiftUI

struct RankingList<T, R, ItemContent: View, SectionHeader: View>: View
where T: LibraryComparable, T: Hashable, T: Archivable, R: Comparable, R: Hashable {
  let items: [T]
  let rankingMapBuilder: ([T]) -> [R: [T]]
  var rankSorted: ((R, R) -> Bool)?
  @ViewBuilder let itemContentView: (T) -> ItemContent
  @ViewBuilder let sectionHeaderView: (R) -> SectionHeader

  @Binding var searchString: String

  private var filteredItems: [T] {
    guard !searchString.isEmpty else { return items }
    return items.filter { $0.name.lowercased().contains(searchString.lowercased()) }
  }

  var body: some View {
    let rankingMap = rankingMapBuilder(filteredItems)
    List {
      ForEach(rankingMap.keys.sorted(by: rankSorted ?? (<)), id: \.self) { ranking in
        if let items = rankingMap[ranking] {
          Section {
            ForEach(items) { item in
              NavigationLink(archivable: item) {
                LabeledContent {
                  itemContentView(item)
                } label: {
                  Text(item.name)
                }
              }
            }
          } header: {
            sectionHeaderView(ranking)
          }
        }
      }
    }
    .listStyle(.plain)
  }
}

struct RankingList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      RankingList(
        items: vault.music.artists,
        rankingMapBuilder: { artists in
          return [Ranking(rank: 1, value: 3): artists]
        },
        rankSorted: >,
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
      .archiveDestinations()
    }

    NavigationStack {
      RankingList(
        items: vault.music.venues,
        rankingMapBuilder: { artists in
          return [Ranking(rank: 1, value: 3): artists]
        },
        itemContentView: { _ in },
        sectionHeaderView: { section in
          Text("Venues")
        },
        searchString: .constant("")
      )
      .navigationTitle("Venues")
      .environment(\.vault, vault)
      .archiveDestinations()
    }
  }
}
