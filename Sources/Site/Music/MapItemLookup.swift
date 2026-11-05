//
//  MapItemLookup.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/4/26.
//

import MapKit
import Shared

/// Every identifier lookup in the app takes its turn here, as MapKit limits them across the app.
enum MapItemLookup {
  // MapKit's window starts with its first request, a little after this one's, so wait a little longer.
  private static let turns = Throttle<Bool>(
    batchSize: MapKitLimits.maxRequests, timeUntilReset: MapKitLimits.timeUntilReset + .seconds(5))

  static func mapItem(for identifier: MKMapItem.Identifier) async throws -> MKMapItem {
    // A throttled lookup fails like an unknown identifier, so staying under the limit is the only guard.
    _ = try await turns.perform { .success(true) }
    return try await MKMapItemRequest(mapItemIdentifier: identifier).mapItem
  }
}
