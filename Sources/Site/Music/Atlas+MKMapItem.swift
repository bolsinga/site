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
    guard let placemark: Placemark = try await geocode(venue) else { return nil }
    return try await placemark.mapItem(for: venue)
  }
}
