//
//  LocatableMap.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import MapKit
import SwiftUI

struct LocatableMap<T: Locatable>: View {
  let location: T

  var body: some View {
    Map(
      coordinateRegion: .constant(location.region),
      interactionModes: MapInteractionModes(),
      annotationItems: [location]
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
    let location = TestLocation(
      center: CLLocationCoordinate2D(latitude: 37.76892200, longitude: -122.45262000), radius: 100)
    LocatableMap(location: location)
  }
}
