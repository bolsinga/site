//
//  PlaceCardButton.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/9/26.
//

import MapKit
import SwiftUI

#if !os(tvOS)
  /// Shows a place's card from Maps, looking the place up when only its identifier is known.
  struct PlaceCardButton: View {
    /// The place, when it's at hand.
    var item: MKMapItem? = nil
    /// The place's identifier, looked up when the card opens.
    var identifier: String? = nil

    @State private var isPresented = false
    @State private var lookedUp: MKMapItem?

    var body: some View {
      Button("Place Card", systemImage: "info.circle") { isPresented = true }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .disabled(item == nil && identifier == nil)
        // The card shows that it's loading until the place is found.
        .mapItemDetailPopover(isPresented: $isPresented, item: item ?? lookedUp)
        .task(id: isPresented) {
          guard isPresented, item == nil, lookedUp == nil, let identifier,
            let mapItemIdentifier = MKMapItem.Identifier(rawValue: identifier)
          else { return }
          lookedUp = try? await MapItemLookup.mapItem(for: mapItemIdentifier)
        }
    }
  }
#endif
