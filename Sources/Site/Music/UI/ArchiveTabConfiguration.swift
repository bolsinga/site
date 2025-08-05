//
//  ArchiveTabConfiguration.swift
//  site
//
//  Created by Greg Bolsinga on 8/7/25.
//

#if canImport(UIKit)
  import UIKit

  extension UIDevice {
    fileprivate var showSettingsInTabView: Bool {
      // Ideally this could check if the TabView was able to show a sidebar.
      userInterfaceIdiom != .phone
    }

    fileprivate var combineTodayAndShowSummary: Bool {
      userInterfaceIdiom == .phone
    }
  }

  @MainActor
  var showSettingsInTabView: Bool {
    UIDevice.current.showSettingsInTabView
  }

  @MainActor
  var combineTodayAndShowSummary: Bool {
    UIDevice.current.combineTodayAndShowSummary
  }
#else
  let showSettingsInTabView = false
  let combineTodayAndShowSummary = false
#endif
