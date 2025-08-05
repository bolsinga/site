//
//  ArchiveSettingsPlacement.swift
//  site
//
//  Created by Greg Bolsinga on 8/5/25.
//

#if canImport(UIKit)
  import UIKit

  extension UIDevice {
    var showSettingsInTabView: Bool {
      // Ideally this could check if the TabView was able to show a sidebar.
      userInterfaceIdiom != .phone
    }
  }

  @MainActor
  var showSettingsInTabView: Bool {
    UIDevice.current.showSettingsInTabView
  }
#endif
