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
  @Binding var placemark: CLPlacemark?

  var body: some View {
    ZStack {
      if let placemark {
        LocatableMap(locations: [placemark])
          .onTapGesture {
            MKMapItem(placemark: MKPlacemark(placemark: placemark)).openInMaps()
          }
      }
    }
  }
}
