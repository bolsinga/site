//
//  LibraryComparableSortModifier.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import SwiftUI

struct LibraryComparableSortModifier: ViewModifier {
  @Binding var algorithm: LibrarySectionAlgorithm

  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          let sortText = Text(
            "Sort", bundle: .module,
            comment: "Shown to change the sort order of the LibraryComparableList.")
          Menu {
            Picker(selection: $algorithm) {
              ForEach(LibrarySectionAlgorithm.allCases, id: \.self) { category in
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
  func sortable(algorithm: Binding<LibrarySectionAlgorithm>) -> some View {
    modifier(LibraryComparableSortModifier(algorithm: algorithm))
  }
}
