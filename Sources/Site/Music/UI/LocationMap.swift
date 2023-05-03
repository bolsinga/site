//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import MapKit
import SwiftUI

extension MKMapItem {
  internal var coordinateRegion: MKCoordinateRegion {
    var radius = 100.0  // meters
    if let circularRegion = self.placemark.region as? CLCircularRegion {
      radius = circularRegion.radius
    }
    return MKCoordinateRegion(
      center: self.placemark.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
  }
}

extension MKMapItem: Identifiable {}

struct LocationMap: View {
  @Environment(\.vault) private var vault: Vault

  let location: Location

  @State private var mapItem: MKMapItem? = nil

  var body: some View {
    ZStack {
      if let mapItem {
        Map(
          coordinateRegion: .constant(mapItem.coordinateRegion),
          interactionModes: MapInteractionModes(), annotationItems: [mapItem]
        ) { mapItem in
          MapMarker(coordinate: mapItem.placemark.coordinate)
        }
        .onTapGesture {
          mapItem.openInMaps()
        }
        .frame(minHeight: 300)
      }
    }.task {
      do { mapItem = try await vault.atlas.geocode(location) } catch {}
    }
  }
}

struct LocationMap_Previews: PreviewProvider {
  static var previews: some View {
    LocationMap(location: Location(city: "Chicago", state: "IL"))
  }
}
