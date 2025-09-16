//
//  LocationMap.swift
//
//
//  Created by Greg Bolsinga on 5/2/23.
//

import MapKit
import SwiftUI

struct LocationMap<T: Equatable>: View {
  typealias geocoder = @MainActor () async throws -> MKMapItem?

  let identifier: T
  let geocode: geocoder?
  @State var item: MKMapItem?
  @State var error: Error?

  var body: some View {
    ZStack {
      if let item {
        Map(
          initialPosition: .rect(item.paddedRect),
          interactionModes: MapInteractionModes()
        ) {
          Marker(item: item)
        }
        .onTapGesture {
          #if !os(tvOS)
            item.openInMaps()
          #endif
        }
      } else if let error = error {
        ContentUnavailableView(
          error.localizedDescription, systemImage: "exclamationmark.magnifyingglass",
          description: Text("Unable to determine map location."))
      } else {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
      }
    }
    .task(id: identifier) {
      guard let geocode else { return }
      do {
        item = try await geocode()
      } catch {
        self.error = error
      }
    }
    .frame(minHeight: 300)
  }
}

#Preview("Progress View") {
  LocationMap(identifier: "hey", geocode: nil)
}

#Preview("Error") {
  @Previewable @State var error = NSError(domain: "domain", code: 0)
  LocationMap(identifier: "hey", geocode: nil, error: error)
}

#Preview("Current Location") {
  @Previewable @State var item = MKMapItem.forCurrentLocation()
  LocationMap(identifier: "hey", geocode: nil, item: item)
}
