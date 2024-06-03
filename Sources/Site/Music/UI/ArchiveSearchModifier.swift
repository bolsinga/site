//
//  ArchiveSearchModifier.swift
//
//
//  Created by Greg Bolsinga on 5/30/23.
//

import SwiftUI

struct ArchiveSearchModifier: ViewModifier {
  let searchPrompt: String

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
  }
}

extension View {
  func archiveSearchable(searchPrompt: String, searchString: Binding<String>, contentsEmpty: Bool)
    -> some View
  {
    modifier(
      ArchiveSearchModifier(
        searchPrompt: searchPrompt, searchString: searchString, contentsEmpty: contentsEmpty))
  }
}
