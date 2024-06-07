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
        ToolbarItem(placement: .primaryAction) {
          let sortText = Text("Sort", bundle: .module)
          Menu {
            Picker(selection: $algorithm) {
              ForEach(T.allCases, id: \.self) { category in
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
}

extension View {
  func sortable<T: Sorting>(algorithm: Binding<T>, algorithmNameBuilder: @escaping (T) -> String)
    -> some View
  {
    modifier(SortModifier(algorithm: algorithm, algorithmNameBuilder: algorithmNameBuilder))
  }
}
