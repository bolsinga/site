//
//  ArchiveSearchModifier.swift
//
//
//  Created by Greg Bolsinga on 5/30/23.
//

import SwiftUI

struct ArchiveSearchModifier: ViewModifier {
  let searchPrompt: String

  @Binding var scope: ArchiveSearchScope
  @Binding var searchString: String
  let contentsEmpty: Bool

  func body(content: Content) -> some View {
    content
      .searchable(text: $searchString, prompt: searchPrompt)
      .overlay {
        if !searchString.isEmpty, contentsEmpty {
          ContentUnavailableView.search(text: searchString)
        }
      }
      .searchScopes($scope) {
        ForEach(ArchiveSearchScope.allCases, id: \.self) {
          Text($0.localizedString).tag($0)
        }
      }
  }
}

extension View {
  func archiveSearchable(
    searchPrompt: String, scope: Binding<ArchiveSearchScope>, searchString: Binding<String>,
    contentsEmpty: Bool
  )
    -> some View
  {
    modifier(
      ArchiveSearchModifier(
        searchPrompt: searchPrompt, scope: scope, searchString: searchString,
        contentsEmpty: contentsEmpty))
  }
}
