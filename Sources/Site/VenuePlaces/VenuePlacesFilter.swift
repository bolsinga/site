//
//  VenuePlacesFilter.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/14/26.
//

import SwiftUI

/// What the filter looks at for a venue.
struct VenueFacts {
  let status: VenuePickStatus
  /// A place was picked or an address accepted since the window opened.
  let isModified: Bool
  let hasStreet: Bool
  /// Geocodes to the same point as another venue, other than the center of its city.
  let sharesLocation: Bool
  let hasWebsite: Bool
  /// Loading the website, or comparing it with Maps', found something to look at.
  let websiteNeedsALook: Bool
  /// Has a MapKit identifier, picked or the archive's.
  let hasPlace: Bool
  /// Maps gave a different address than the venue's.
  let addressDiffers: Bool
  /// Maps now knows the venue's place by another identifier.
  let identifierChanged: Bool
  /// Maps can't find the venue's place.
  let placeGone: Bool
}

/// Which venues the list shows, one at a time; with none, it shows every venue.
enum VenuePlacesFilter: Hashable {
  case modified
  case suggested
  case noStreet
  case sharesLocation
  case noWebsite
  case websiteNeedsALook
  case noMapKitID
  case addressDiffers
  case identifierChanged
  case placeGone

  /// How far along each venue is.
  static var statuses: [Self] { [.modified, .suggested] }

  /// What might be wrong with a venue.
  static var criteria: [Self] {
    [
      .noStreet, .sharesLocation, .noWebsite, .websiteNeedsALook, .noMapKitID, .addressDiffers,
      .identifierChanged,
      .placeGone,
    ]
  }

  var label: LocalizedStringResource {
    switch self {
    case .modified: "Modified"
    case .suggested: "Suggested"
    case .noStreet: "No Street (City Center)"
    case .sharesLocation: "Shares a Location"
    case .noWebsite: "No Website"
    case .websiteNeedsALook: "Website Needs a Look"
    case .noMapKitID: "No MapKit Identifier"
    case .addressDiffers: "Address Differs from Maps"
    case .identifierChanged: "Identifier Changed"
    case .placeGone: "Place Gone"
    }
  }

  func includes(_ facts: VenueFacts) -> Bool {
    switch self {
    case .modified: facts.isModified
    case .suggested: facts.status == .suggested
    case .noStreet: !facts.hasStreet
    case .sharesLocation: facts.sharesLocation
    case .noWebsite: !facts.hasWebsite
    case .websiteNeedsALook: facts.websiteNeedsALook
    case .noMapKitID: !facts.hasPlace
    case .addressDiffers: facts.addressDiffers
    case .identifierChanged: facts.identifierChanged
    case .placeGone: facts.placeGone
    }
  }
}
