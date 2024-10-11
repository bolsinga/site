//
//  NSUserActivity+Search.swift
//  site
//
//  Created by Greg Bolsinga on 10/11/24.
//

import CoreSpotlight
import Foundation

extension NSUserActivity {
  func addSearchableContent(description: String) {
    #if !os(tvOS)
      let attributes = CSSearchableItemAttributeSet(contentType: .content)
      attributes.contentDescription = description
      self.contentAttributeSet = attributes
    #endif
  }
}
