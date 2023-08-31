//
//  PathRestorableShareModifier.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

struct PathRestorableShareModifier<T: PathRestorableShareable>: ViewModifier {
  let item: T
  let url: URL?

  func body(content: Content) -> some View {
    content
      .toolbar {
        if let url {
          ShareLink(item: url, subject: item.subject, message: item.message)
        }
      }
  }
}

extension View {
  func sharePathRestorable<T: PathRestorableShareable>(_ item: T, url: URL?) -> some View {
    modifier(PathRestorableShareModifier(item: item, url: url))
  }
}
