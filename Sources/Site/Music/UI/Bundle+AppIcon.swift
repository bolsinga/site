//
//  File.swift
//
//
//  Created by Greg Bolsinga on 9/11/23.
//

import SwiftUI

extension Image {
  fileprivate static var fallbackAppIcon: Image {
    Image(systemName: "questionmark.circle")
  }

  fileprivate static func appIcon(named: String?) -> Image {
    guard let named else { return Self.fallbackAppIcon }
    #if canImport(UIKit)
      guard let pImage = UIImage(named: named) else { return Self.fallbackAppIcon }
      return Image(uiImage: pImage)
    #else
      guard let pImage = NSImage(named: named) else { return Self.fallbackAppIcon }
      return Image(nsImage: pImage)
    #endif
  }
}

extension Bundle {
  private var appIconName: String? {
    #if os(iOS) || os(tvOS)
      guard
        let icons = self.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
        let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
        let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
        let iconFileName = iconFiles.last
      else { return nil }
      return iconFileName
    #else
      "AppIcon"
    #endif
  }

  var appIcon: Image {
    Image.appIcon(named: appIconName)
  }
}
