//
//  Atlas+MKMapItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/30/25.
//

import Foundation
import MapKit

extension Atlas where T == Venue {
  nonisolated func geocode(_ venue: T) async throws -> MKMapItem? {
    guard let location = try await geocode(venue)?.location else { return nil }
    return MKMapItem(venue: venue, location: location)
  }
}
