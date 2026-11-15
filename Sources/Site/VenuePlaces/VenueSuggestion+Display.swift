//
//  VenueSuggestion+Display.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/26.
//

import Shared
import SwiftUI

extension VenueAddressPickStore {
  /// The address the venue has: the accepted one, or the archive's.
  func address(for venue: Venue) -> VenueAddress {
    self[venue.id] ?? VenueAddress(venue.location)
  }
}

extension AddressCheck {
  /// The address Maps gave, when it differs.
  var differingAddress: VenueAddress? {
    guard case .differs(let found) = self else { return nil }
    return found
  }
}

extension SuggestionConfidence {
  var label: LocalizedStringResource {
    switch self {
    case .strong: "Strong match"
    case .medium: "Likely match"
    case .weak: "Weak match"
    }
  }

  var systemImage: String {
    switch self {
    case .strong: "checkmark.circle.fill"
    case .medium: "circle.lefthalf.filled"
    case .weak: "questionmark.circle"
    }
  }

  var color: Color {
    switch self {
    case .strong: .green
    case .medium: .orange
    case .weak: .secondary
    }
  }
}
