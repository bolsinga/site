//
//  SortModifierToolbarContent.swift
//  site
//
//  Created by Greg Bolsinga on 10/1/24.
//

import SwiftUI

struct SortModifierToolbarContent<T: Sorting>: ToolbarContent {
  @Binding var algorithm: T
  let algorithmNameBuilder: (T) -> String

  var body: some ToolbarContent {
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
