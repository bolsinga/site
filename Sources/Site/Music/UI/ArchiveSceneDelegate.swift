//
//  ArchiveSceneDelegate.swift
//
//
//  Created by Greg Bolsinga on 9/9/24.
//

#if os(iOS)
  import UIKit

  class ArchiveSceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
      _ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem
    ) async -> Bool {
      print("here")
      return true
    }
  }
#endif
