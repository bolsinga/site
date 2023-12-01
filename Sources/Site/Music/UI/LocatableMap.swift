//
//  LocatableMap.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import MapKit
import SwiftUI

struct LocatableMap<T>: View where T: Locatable, T: Equatable {
  let location: T

  var body: some View {
    Map(
      mapRect: .constant(location.paddedRect),
      interactionModes: MapInteractionModes(),
      annotationItems: [location]
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

  return LocatableMap(location: PreviewLocation())
}
