//
//  ArchiveAppDelegate.swift
//
//
//  Created by Greg Bolsinga on 9/9/24.
//

#if !os(macOS)
  import UIKit

  public class ArchiveAppDelegate: NSObject, UIApplicationDelegate {
    override init() {
      self.thing = 0
    }

    public var thing: Int {
      didSet {

      }
    }

    public var archiveNavigation: ArchiveNavigation?

    #if os(iOS)
      public func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
      ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
          name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = ArchiveSceneDelegate.self
        return configuration
      }
    #endif
  }
#endif
