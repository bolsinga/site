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

struct LocatableMap_Previews: PreviewProvider {
  struct TestLocation: Locatable, Equatable {
    static func == (
      lhs: LocatableMap_Previews.TestLocation, rhs: LocatableMap_Previews.TestLocation
    ) -> Bool {
      return lhs.id == rhs.id && lhs.radius == rhs.radius
    }

    let uuid = UUID()

    var id: UUID { uuid }

    let center: CLLocationCoordinate2D
    let radius: CLLocationDistance
  }

  struct Inner: View {
    @State private var locations: [TestLocation] = []

    var body: some View {
      LocatableMap(locations: $locations)
        .task {
          let location1 = TestLocation(
            center: CLLocationCoordinate2D(latitude: 37.76892200, longitude: -122.45262000),
            radius: 100)
          let location2 = TestLocation(
            center: CLLocationCoordinate2D(latitude: 37.7839308, longitude: -122.43311559999999),
            radius: 100)

          do {
            try await Task.sleep(for: .seconds(2))
            locations.append(location1)
            try await Task.sleep(for: .seconds(4))
            locations.append(location2)
          } catch {}
        }
    }
  }

  static var previews: some View {
    Inner()
  }
}
