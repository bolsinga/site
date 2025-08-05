//
//  ShowsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct ShowsSummary: View {
  @Environment(VaultModel.self) var model
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold
  @AppStorage("nearby.filter") private var nearbyFilter = LocationFilter.default

  var body: some View {
    let decadesMap = model.filteredDecadesMap(
      locationFilter: nearbyFilter, distanceThreshold: nearbyDistance)
    ShowYearList(decadesMap: decadesMap)
      .nearbyLocation(filteredDataIsEmpty: decadesMap.isEmpty)
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  ShowsSummary()
}
