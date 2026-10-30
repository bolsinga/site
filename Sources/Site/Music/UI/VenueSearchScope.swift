//
//  VenueSearchScope.swift
//  site
//
//  Created by Greg Bolsinga on 10/29/26.
//

import Foundation

enum VenueSearchScope: CaseIterable {
  case names
  case cities

  var localizedString: String {
    switch self {
    case .names:
      String(localized: "Venue Names", comment: "VenueSearchScope.names")
    case .cities:
      String(localized: "Cities", comment: "VenueSearchScope.cities")
    }
  }

  /// The prompt while search is not active, before a scope is in play.
  static var idlePrompt: String {
    String(localized: "Search Venues", comment: "VenueSearchScope idle prompt")
  }

  var searchPrompt: String {
    switch self {
    case .names:
      String(localized: "Venue Names", comment: "VenueSearchScope.names prompt")
    case .cities:
      String(localized: "City Name", comment: "VenueSearchScope.cities prompt")
    }
  }
}
