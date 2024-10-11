//
//  ArchiveSharableModifier.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

struct ArchiveSharableModifier<T: ArchiveSharable>: ViewModifier {
  let item: T?

  func body(content: Content) -> some View {
    content
      .toolbar { ArchiveSharableToolbarContent(item: item) }
  }
}

extension View {
  func archiveShare<T: ArchiveSharable>(_ item: T?) -> some View {
    modifier(ArchiveSharableModifier(item: item))
  }
}
