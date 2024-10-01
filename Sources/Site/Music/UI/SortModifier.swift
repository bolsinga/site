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

struct SortModifier<T: Sorting>: ViewModifier {
  @Binding var algorithm: T
  let algorithmNameBuilder: (T) -> String

  func body(content: Content) -> some View {
    content
      .toolbar {
        SortModifierToolbarContent(
          algorithm: $algorithm, algorithmNameBuilder: algorithmNameBuilder)
      }
  }
}

extension View {
  func sortable<T: Sorting>(algorithm: Binding<T>, algorithmNameBuilder: @escaping (T) -> String)
    -> some View
  {
    modifier(SortModifier(algorithm: algorithm, algorithmNameBuilder: algorithmNameBuilder))
  }
}
