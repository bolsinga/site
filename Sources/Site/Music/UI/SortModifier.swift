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

  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          let sortText = Text(
            "Sort", bundle: .module,
            comment: "Shown to change the sort order of the LibraryComparableList.")
          Menu {
            Picker(selection: $algorithm) {
              ForEach(T.allCases, id: \.self) { category in
                Text(category.localizedString).tag(category)
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
}

extension View {
  func sortable<T: Sorting>(algorithm: Binding<T>) -> some View {
    modifier(SortModifier(algorithm: algorithm))
  }
}
