//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import MapKit
import SwiftUI

struct LocationMap: View {
  let item: MKMapItem?

  var body: some View {
    ZStack {
      if let item {
        Map(
          initialPosition: .rect(item.paddedRect),
          interactionModes: MapInteractionModes()
        ) {
          Marker(item: item)
        }
      }
    }
  }
}
