//
//  String+AttributedMatching.swift
//
//
//  Created by Greg Bolsinga on 6/15/24.
//

import Foundation
import SwiftUI

extension String {
  func emphasizedAttributed(matching fragment: String) -> AttributedString {
    let markdown = self.emphasized(matching: fragment)
    guard let emphasized = try? AttributedString(markdown: markdown) else {
      return AttributedString(self)
    }
    return emphasized
  }
}

#Preview {
  VStack {
    Text("Greg Bolsinga".emphasizedAttributed(matching: "G"))
    Text("Greg Bolsinga".emphasizedAttributed(matching: "G "))
    Text("Greg Bolsinga".emphasizedAttributed(matching: "G B"))
    Text("Greg Bolsinga".emphasizedAttributed(matching: " B"))
    Text("Greg Bolsinga".emphasizedAttributed(matching: "B"))
  }
}
