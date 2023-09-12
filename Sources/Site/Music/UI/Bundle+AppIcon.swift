//
//  File.swift
//
//
//  Created by Greg Bolsinga on 9/11/23.
//

import SwiftUI

extension Bundle {
  var appIcon: Image {
    #if os(iOS)
      guard let pImage = UIImage(named: "AppIcon") else {
        return Image(systemName: "questionmark.circle")
      }
      return Image(uiImage: pImage)
    #elseif os(macOS)
      guard let pImage = NSImage(named: "AppIcon") else {
        return Image(systemName: "questionmark.circle")
      }
      return Image(nsImage: pImage)
    #endif
  }
}
