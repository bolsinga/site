//
//  SiteAppApp.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/24/23.
//

import SwiftUI

@main
struct SiteAppApp: App {
  @State private var model = SiteModel(urlString: "https://www.bolsinga.com/json/shows.json")

  init() {
    SiteShortcuts.updateAppShortcutParameters()
  }

  var body: some Scene {
    WindowGroup {
      SiteView(model)
    }
    #if !os(tvOS)
      .commands {
        RefreshCommand { await model.load() }
      }
    #endif
    #if os(macOS)
      Settings { SettingsView() }
    #endif
  }
}
