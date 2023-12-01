//
//  LocatableMap.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import MapKit
import SwiftUI

struct LocatableMap<T>: View where T: Locatable, T: Equatable {
  let locations: [T]
  @State var mapRect: MKMapRect

  internal init(locations: [T]) {
    self.locations = locations
    self.mapRect = locations.paddedRect
  }

  var body: some View {
    Map(
      mapRect: $mapRect,
      interactionModes: MapInteractionModes(),
      annotationItems: locations
    ) { item in
      MapMarker(coordinate: item.center)
    }
  }
}

#Preview {
  struct PreviewLocation: Locatable, Equatable {
    var id: UUID { UUID() }
    var center: CLLocationCoordinate2D {
      CLLocationCoordinate2D(latitude: 37.76892200, longitude: -122.45262000)
    }
    var radius: CLLocationDistance { 100.0 }
  }

  return LocatableMap(locations: [PreviewLocation()])
}
