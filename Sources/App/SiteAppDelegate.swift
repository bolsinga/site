//
//  SiteAppDelegate.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/22/26.
//

#if os(iOS)
  import Shared
  import UIKit

  extension UIApplicationShortcutItem {
    private static let typePrefix = "gdb.SiteApp.quickAction."

    fileprivate static let categories: [ArchiveCategory] = [.today, .shows, .venues, .artists]

    fileprivate convenience init(category: ArchiveCategory) {
      self.init(
        type: Self.typePrefix + category.rawValue,
        localizedTitle: category.localizedString,
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(systemImageName: category.systemImage),
        userInfo: nil)
    }

    var category: ArchiveCategory? {
      guard type.hasPrefix(Self.typePrefix) else { return nil }
      return ArchiveCategory(rawValue: String(type.dropFirst(Self.typePrefix.count)))
    }
  }

  /// UIKit-only events become the same `NSUserActivity`s SwiftUI's `onContinueUserActivity` handles,
  /// so nothing here knows about the app's navigation.
  final class SiteAppDelegate: NSObject, UIApplicationDelegate {
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
      application.shortcutItems = UIApplicationShortcutItem.categories.map {
        UIApplicationShortcutItem(category: $0)
      }
      return true
    }

    func application(
      _ application: UIApplication,
      configurationForConnecting connectingSceneSession: UISceneSession,
      options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
      let configuration = UISceneConfiguration(
        name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
      configuration.delegateClass = SiteSceneDelegate.self
      return configuration
    }
  }
#endif
