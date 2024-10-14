//
//  RankingList.swift
//
//
//  Created by Greg Bolsinga on 6/3/23.
//

import SwiftUI

struct RankingList<T, R, ItemContent: View, SectionHeader: View, LabelContent: View>: View
where T: LibraryComparable, T: Hashable, T: PathRestorable, R: Comparable, R: Hashable {
  let items: [T]
  let rankingMapBuilder: ([T]) -> [R: [T]]
  var rankSorted: ((R, R) -> Bool)?
  @ViewBuilder let itemContentView: (T) -> ItemContent
  @ViewBuilder let sectionHeaderView: (R) -> SectionHeader
  @ViewBuilder let itemLabelView: ((T) -> LabelContent)

  var body: some View {
    let rankingMap = rankingMapBuilder(items)
    List {
      ForEach(rankingMap.keys.sorted(by: rankSorted ?? (<)), id: \.self) { ranking in
        if let items = rankingMap[ranking] {
          Section {
            ForEach(items) { item in
              NavigationLink(value: item) {
                LabeledContent {
                  itemContentView(item)
                } label: {
                  itemLabelView(item)
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

#Preview {
  RankingList(
    items: vaultPreviewData.artistDigests,
    rankingMapBuilder: { artists in
      return [Ranking(rank: .rank(1), value: 3): artists]
    },
    rankSorted: >,
    itemContentView: { _ in
      Text(3.formatted(.number))
    },
    sectionHeaderView: { section in
      Text("Artists")
    },
    itemLabelView: { Text($0.name) }
  )
}

#Preview {
  RankingList(
    items: vaultPreviewData.venueDigests,
    rankingMapBuilder: { artists in
      return [Ranking(rank: .rank(1), value: 3): artists]
    },
    itemContentView: { _ in },
    sectionHeaderView: { section in
      Text("Venues")
    },
    itemLabelView: { Text($0.name) }
  )
}
