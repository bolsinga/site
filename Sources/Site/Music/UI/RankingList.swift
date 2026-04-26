//
//  RankingList.swift
//
//
//  Created by Greg Bolsinga on 6/3/23.
//

import SwiftUI

struct RankingList<
  T: Identifiable & PathRestorable,
  R: Comparable & Hashable,
  ItemContent: View,
  SectionHeader: View,
  LabelContent: View
>: View {
  let rankingMap: [R: [T]]
  let compare: (T, T) -> Bool
  let rankSorted: ((R, R) -> Bool)
  @ViewBuilder let itemContentView: (T) -> ItemContent
  @ViewBuilder let sectionHeaderView: (R) -> SectionHeader
  @ViewBuilder let itemLabelView: ((T) -> LabelContent)

  var body: some View {
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
    rankingMap: [Ranking(rank: .rank(1), value: 3): Array(model.previewAllArtists)],
    compare: model.compare(lhs:rhs:),
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
    rankingMap: [Ranking(rank: .rank(1), value: 3): Array(model.previewAllVenues)],
    compare: model.compare(lhs:rhs:),
    rankSorted: <,
    itemContentView: { _ in },
    sectionHeaderView: { section in
      Text("Venues")
    },
    itemLabelView: { Text($0.name) }
  )
}
