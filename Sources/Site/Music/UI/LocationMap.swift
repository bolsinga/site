//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import MapKit
import SwiftUI

struct LocationMap: View {
  let geocodingInProgress: Bool
  @Binding var item: MKMapItem?

  var body: some View {
    ZStack {
      if let item {
        Map(
          initialPosition: .rect(item.paddedRect),
          interactionModes: MapInteractionModes()
        ) {
          Marker(item: item)
        }
        .tint(.accentColor)
        .onTapGesture {
          #if !os(tvOS)
            item.openInMaps()
          #endif
        }
      } else if geocodingInProgress {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
      } else {
        ContentUnavailableView(
          String(localized: "Map Location Unavailable"),
          systemImage: "mappin.slash.circle",
          description: Text("Unable to determine map location."))
      }
    }
    .frame(minHeight: 300)
  }
}

#Preview("Progress View") {
  LocationMap(geocodingInProgress: true, item: .constant(nil))
}

#Preview("Unavailable View") {
  LocationMap(geocodingInProgress: false, item: .constant(nil))
}

#Preview("Current Location") {
  @Previewable @State var item = MKMapItem.forCurrentLocation()
  LocationMap(geocodingInProgress: false, item: .constant(item))
}
