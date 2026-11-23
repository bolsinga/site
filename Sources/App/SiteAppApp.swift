//
//  SiteAppApp.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/24/23.
//

import AppIntents
import Shared
import SiteCore
import SwiftUI

struct SiteAppApp: App {
  #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: SiteAppDelegate
  #endif
  @State private var model: SiteModel

  init() {
    let urlString =
      URL.archiveRoot?.appendingPathComponent("json/shows.json").absoluteString ?? ""
    // Intents can run before there is a scene to load the archive, so they get it from this.
    let provider = VaultProvider(urlString: urlString)
    AppDependencyManager.shared.add(dependency: provider)
    EntityVault.provider = provider

    let model = SiteModel(urlString: urlString)
    model.vaultProvider = provider
    #if !os(tvOS)
      model.indexSpotlight = { await $0.indexForSpotlight() }
    #endif
    _model = State(initialValue: model)

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
          // Restoration only covers a window left open, so it also saves its own frame.
          .windowFrameAutosave(VenuePlaces.windowFrameName)
      }
      .defaultWindowPlacement { _, context in
        let frame = VenuePlaces.defaultWindowPlacement(in: context.defaultDisplay.visibleRect)
        return WindowPlacement(frame.origin, size: frame.size)
      }
      .commandsReplaced { VenuePlacesCommand() }
      .defaultLaunchBehavior(.suppressed)
      // Reopens if left open, but never in builds where the tool isn't enabled.
      .restorationBehavior(VenuePlaces.isEnabled ? .automatic : .disabled)
    #endif
  }
}
