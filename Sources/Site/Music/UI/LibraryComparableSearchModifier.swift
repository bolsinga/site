//
//  LibraryComparableSearchModifier.swift
//
//
//  Created by Greg Bolsinga on 5/30/23.
//

import SwiftUI

struct LibraryComparableSearchModifier: ViewModifier {
  let searchPrompt: String

  @Binding var searchString: String

  func body(content: Content) -> some View {
    content
      .searchable(text: $searchString, prompt: searchPrompt)
  }
}

extension View {
  func libraryComparableSearchable(searchPrompt: String, searchString: Binding<String>) -> some View
  {
    modifier(
      LibraryComparableSearchModifier(searchPrompt: searchPrompt, searchString: searchString))
  }
}
