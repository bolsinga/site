//
//  SortModifierToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct SortModifierToolbarContent: ToolbarContent {
  let placement: ToolbarItemPlacement
  @Binding var algorithm: RankingSort
  let algorithmNameBuilder: (RankingSort) -> String

  internal init(
    placement: ToolbarItemPlacement = .primaryAction, algorithm: Binding<RankingSort>,
    algorithmNameBuilder: @escaping (RankingSort) -> String
  ) {
    self.placement = placement
    self._algorithm = algorithm
    self.algorithmNameBuilder = algorithmNameBuilder
  }

  var body: some ToolbarContent {
    ToolbarItem(placement: placement) {
      let sortText = Text("Sort", bundle: .module)
      Menu {
        Picker(selection: $algorithm) {
          ForEach(RankingSort.allCases, id: \.self) { category in
            Text(algorithmNameBuilder(category)).tag(category)
          }
        } label: {
          sortText
        }
      } label: {
        Label {
          sortText
        } icon: {
          Image(systemName: "line.3.horizontal.decrease.circle")
        }
      }
    }
  }
}
