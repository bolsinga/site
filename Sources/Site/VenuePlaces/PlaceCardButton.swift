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
    @State private var isLookingUp = false
    @State private var lookupFailed = false
    @State private var lookedUp: MKMapItem?

    var body: some View {
      Button {
        if item == nil && lookedUp == nil {
          Task { await lookUp() }
        } else {
          isPresented = true
        }
      } label: {
        if isLookingUp {
          ProgressView().controlSize(.small)
        } else {
          Label("Place Card", systemImage: "info.circle").labelStyle(.iconOnly)
        }
      }
      .buttonStyle(.borderless)
      .disabled(isLookingUp || (item == nil && identifier == nil))
      // The card opens once the place is found, as it doesn't update when it's shown without one.
      .mapItemDetailPopover(isPresented: $isPresented, item: item ?? lookedUp)
      .alert("Place Not Found", isPresented: $lookupFailed) {
      } message: {
        Text("Maps couldn't find this place.")
      }
    }

    private func lookUp() async {
      guard let identifier, let mapItemIdentifier = MKMapItem.Identifier(rawValue: identifier)
      else { return }
      isLookingUp = true
      defer { isLookingUp = false }
      do {
        lookedUp = try await MapItemLookup.mapItem(for: mapItemIdentifier)
        isPresented = true
      } catch {
        lookupFailed = true
      }
    }
  }
#endif
