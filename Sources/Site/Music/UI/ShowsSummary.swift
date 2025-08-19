//
//  ShowsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct ShowsSummary: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  var body: some View {
    let decadesMap = model.filteredDecadesMap(nearbyModel, distanceThreshold: nearbyDistance)
    ShowYearList(decadesMap: decadesMap)
      .nearbyLocation(filteredDataIsEmpty: decadesMap.isEmpty)
  }
}

#Preview(traits: .modifier(NearbyPreviewModifer()), .modifier(VaultPreviewModifier())) {
  ShowsSummary()
}
