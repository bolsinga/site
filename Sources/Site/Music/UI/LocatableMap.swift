//
//  LocatableMap.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import MapKit
import SwiftUI

struct LocatableMap<T>: View where T: Locatable, T: Equatable {
  @Binding var locations: [T]
  @State var mapRect: MKMapRect = .world

  var body: some View {
    Map(
      mapRect: $mapRect,
      interactionModes: MapInteractionModes(),
      annotationItems: locations
    ) { item in
      MapMarker(coordinate: item.center)
    }
    .onAppear {
      mapRect = locations.paddedRect
    }
    .onChange(of: locations) { _, newValue in
      withAnimation {
        mapRect = newValue.paddedRect
      }
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

  return LocatableMap(locations: .constant([PreviewLocation()]))
}
