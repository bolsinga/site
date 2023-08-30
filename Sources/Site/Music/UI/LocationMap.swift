//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import CoreLocation
import MapKit
import SwiftUI

extension CLPlacemark: Identifiable {}

struct LocationMap: View {
  let location: Location
  let geocode: (Location) async throws -> CLPlacemark

  @State private var placemark: CLPlacemark? = nil

  var body: some View {
    ZStack {
      if let placemark {
        LocatableMap(locations: .constant([placemark]))
          .onTapGesture {
            MKMapItem(placemark: MKPlacemark(placemark: placemark)).openInMaps()
          }
      }
    }.task(id: location) {
      do { placemark = try await geocode(location) } catch {}
    }
  }
}

struct LocationMap_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    LocationMap(location: vault.venues[0].location) {
      try await vault.atlas.geocode($0)
    }
  }
}
