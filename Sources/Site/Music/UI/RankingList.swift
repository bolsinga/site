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
  let compare: (T, T) -> Bool
  let rankSorted: ((R, R) -> Bool)
  @ViewBuilder let itemContentView: (T) -> ItemContent
  @ViewBuilder let sectionHeaderView: (R) -> SectionHeader
  @ViewBuilder let itemLabelView: ((T) -> LabelContent)

  var body: some View {
    let rankingMap = rankingMapBuilder(items)
    List {
      ForEach(rankingMap.keys.sorted(by: rankSorted), id: \.self) { ranking in
        if let items = rankingMap[ranking] {
          Section {
            ForEach(items.sorted(by: compare)) { item in
              NavigationLink(value: item.archivePath) {
                LabeledContent {
                  itemContentView(item)
                } label: {
                  itemLabelView(item)
                }
              }
            }
          } header: {
            sectionHeaderView(ranking)
              .frame(maxWidth: .infinity, alignment: .leading)
              .sectionHeaderBackground()
          }
        }
      }
    }
    .listStyle(.plain)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  RankingList(
    items: Array(model.vault.artistDigestMap.values.shuffled()),
    rankingMapBuilder: { artists in
      [Ranking(rank: .rank(1), value: 3): artists]
    },
    compare: model.vault.compare(lhs:rhs:),
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

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  RankingList(
    items: Array(model.vault.venueDigestMap.values.shuffled()),
    rankingMapBuilder: { venues in
      [Ranking(rank: .rank(1), value: 3): venues]
    },
    compare: model.vault.compare(lhs:rhs:),
    rankSorted: <,
    itemContentView: { _ in },
    sectionHeaderView: { section in
      Text("Venues")
    },
    itemLabelView: { Text($0.name) }
  )
}
