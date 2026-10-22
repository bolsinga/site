//
//  SiteSceneDelegate.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/22/26.
//

#if os(iOS)
  import Shared
  import UIKit

  final class SiteSceneDelegate: NSObject, UIWindowSceneDelegate {
    /// A cold launch's quick action waits until the scene is active and SwiftUI is listening.
    private var pendingCategory: ArchiveCategory?

    func scene(
      _ scene: UIScene, willConnectTo session: UISceneSession,
      options connectionOptions: UIScene.ConnectionOptions
    ) {
      pendingCategory = connectionOptions.shortcutItem?.category
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
      guard let category = pendingCategory else { return }
      pendingCategory = nil
      continueActivity(for: category, in: scene)
    }

    func windowScene(
      _ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem,
      completionHandler: @escaping (Bool) -> Void
    ) {
      guard let category = shortcutItem.category else {
        completionHandler(false)
        return
      }
      continueActivity(for: category, in: windowScene)
      completionHandler(true)
    }

    /// iPhone doesn't support multiple scenes, so `requestSceneSessionActivation` fails; hand the activity to the scene as Handoff does.
    private func continueActivity(for category: ArchiveCategory, in scene: UIScene) {
      let activity = NSUserActivity(activityType: ArchiveCategory.activityType)
      activity.addUserInfoEntries(from: [NSUserActivity.archiveCategoryKey: category.rawValue])
      scene.delegate?.scene?(scene, continue: activity)
    }
  }
#endif
