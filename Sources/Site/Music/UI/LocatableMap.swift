//
//  LocatableMap.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import MapKit
import SwiftUI

struct LocatableMap<T: Locatable>: View {
  let locations: [T]

  var body: some View {
    Map(
      mapRect: .constant(locations.paddedRect),
      interactionModes: MapInteractionModes(),
      annotationItems: locations
    ) { item in
      MapMarker(coordinate: item.center)
    }
  }
}

struct LocatableMap_Previews: PreviewProvider {
  struct TestLocation: Locatable {
    let uuid = UUID()

    var id: UUID { uuid }

    let center: CLLocationCoordinate2D
    let radius: CLLocationDistance
  }

  static var previews: some View {
    let location1 = TestLocation(
      center: CLLocationCoordinate2D(latitude: 37.76892200, longitude: -122.45262000), radius: 100)
    let location2 = TestLocation(
      center: CLLocationCoordinate2D(latitude: 37.7839308, longitude: -122.43311559999999),
      radius: 100)
    LocatableMap(locations: [location1, location2])
  }
}
