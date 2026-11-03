//
//  SiteAppApp.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/24/23.
//

import Shared
import SwiftUI

struct SiteAppApp: App {
  #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: SiteAppDelegate
  #endif
  @State private var model = SiteModel(
    urlString: URL.archiveRoot?.appendingPathComponent("json/shows.json").absoluteString ?? "")

  init() {
    SiteShortcuts.updateAppShortcutParameters()
  }

  var body: some Scene {
    WindowGroup {
      SiteView(model)
    }
    #if !os(tvOS)
      .commands {
        RefreshCommand { await model.load(.refresh) }
      }
    #endif
    #if os(macOS)
      Settings { SettingsView() }
      // The command opens it only where the tool is enabled, so the window menu doesn't list it.
      Window("Venue Places", id: VenuePlaces.windowID) {
        VenuePlacesView(model: model)
      }
      .commandsReplaced { VenuePlacesCommand() }
      .defaultLaunchBehavior(.suppressed)
      .restorationBehavior(.disabled)
    #endif
  }
}
