//
//  VenuesMode.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/29/26.
//

import Foundation
import SiteCore

enum VenuesMode: Int, CaseIterable, Codable, Sendable {
  /// Venues on a Map..
  case map

  /// Venues listed and grouped by name.
  case grouped

  static var `default`: Self { .grouped }

  var systemImage: String {
    switch self {
    case .map:
      "map"
    case .grouped:
      "list.bullet"
    }
  }

  var localizedString: String {
    switch self {
    case .map:
      String(localized: "Map", bundle: #bundle)
    case .grouped:
      String(localized: "List", bundle: #bundle)
    }
  }
}
