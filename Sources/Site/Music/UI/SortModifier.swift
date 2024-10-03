//
//  SortModifier.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import SwiftUI

protocol Sorting: CaseIterable, Hashable where AllCases: RandomAccessCollection {
  var localizedString: String { get }
}

struct SortModifier: ViewModifier {
  @Binding var algorithm: RankingSort
  let algorithmNameBuilder: (RankingSort) -> String

  func body(content: Content) -> some View {
    content
      .toolbar {
        SortModifierToolbarContent(
          algorithm: $algorithm, algorithmNameBuilder: algorithmNameBuilder)
      }
  }
}

extension View {
  func sortable(
    algorithm: Binding<RankingSort>, algorithmNameBuilder: @escaping (RankingSort) -> String
  )
    -> some View
  {
    modifier(SortModifier(algorithm: algorithm, algorithmNameBuilder: algorithmNameBuilder))
  }
}
