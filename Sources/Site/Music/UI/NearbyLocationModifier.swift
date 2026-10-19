//
//  NearbyLocationModifier.swift
//  site
//
//  Created by Greg Bolsinga on 10/6/24.
//

import SwiftUI

struct NearbyLocationModifier: ViewModifier {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel

  let filteredDataIsEmpty: Bool

  /// Shows the progress over the content, instead of pushing the content down below it.
  let floatsProgress: Bool

  private var progress: some View {
    NearbyProgressView(
      locationAuthorization: model.locationAuthorization,
      geocodingProgress: model.geocodingProgress, floating: floatsProgress)
  }

  func body(content: Content) -> some View {
    VStack {
      if nearbyModel.locationFilter.isNearby, !floatsProgress {
        progress
      }
      content
    }
    .overlay(alignment: .top) {
      if nearbyModel.locationFilter.isNearby, floatsProgress {
        progress
      }
    }
    .overlay {
      if nearbyModel.locationFilter.isNearby {
        NearbyLocationView(
          locationAuthorization: model.locationAuthorization,
          filteredDataIsEmpty: filteredDataIsEmpty)
      }
    }
  }
}

extension View {
  func nearbyLocation(filteredDataIsEmpty: Bool, floatsProgress: Bool = false) -> some View {
    modifier(
      NearbyLocationModifier(
        filteredDataIsEmpty: filteredDataIsEmpty, floatsProgress: floatsProgress))
  }
}
