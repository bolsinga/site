//
//  ExternalEvent.swift
//  site
//

import Foundation

// Captured at the scene root so it survives arriving before ArchiveNavigation exists
// (e.g. a cold launch, before the vault has finished loading).
struct ExternalEvent: Identifiable {
  enum Kind {
    case url(URL)
    case path(NSUserActivity)
    case category(NSUserActivity)
  }

  let id = UUID()
  let kind: Kind
}
