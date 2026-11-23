//
//  SiteAppApp.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 3/24/23.
//

import AppIntents
import Shared
import SiteCore
import SiteUI
import SwiftUI

#if !os(tvOS)
  import WidgetKit
#endif

struct SiteAppApp: App {
  #if os(iOS)
    @UIApplicationDelegateAdaptor private var appDelegate: SiteAppDelegate
  #endif
  @State private var model: SiteModel
  private let launchMode = LaunchMode()

  init() {
    let urlString =
      URL.archiveRoot?.appendingPathComponent("json/shows.json").absoluteString ?? ""
    // Intents can run before there is a scene to load the archive, so they get it from this.
    let model = SiteModel(urlString: urlString)
    _model = State(initialValue: model)
    guard launchMode == .normal else { return }

    let provider = VaultProvider(urlString: urlString)
    AppDependencyManager.shared.add(dependency: provider)
    EntityVault.provider = provider

    model.vaultProvider = provider
    #if !os(tvOS)
      model.indexSpotlight = { await $0.indexForSpotlight() }
      model.reloadWidgetTimelines = {
        WidgetCenter.shared.reloadTimelines(ofKind: ShowsTodayWidgetKind.kind)
      }
    #endif

    SiteShortcuts.updateAppShortcutParameters()
  }

  var body: some Scene {
    WindowGroup {
      if launchMode == .normal {
        SiteView(model)
          .environment(\.appHooks, .app)
      }
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
