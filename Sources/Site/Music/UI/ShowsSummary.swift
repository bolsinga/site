//
//  ShowsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import Shared
import SwiftUI

struct ShowsSummary: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel
  @AppStorage("nearby.distance") private var nearbyDistance = defaultNearbyDistanceThreshold

  var body: some View {
    let decadesMap = model.filteredDecadesMap(nearbyModel, distanceThreshold: nearbyDistance)
    let years = decadesMap.values.reduce(0) { $0 + $1.count }
    let shows = decadesMap.values.reduce(0) { $0 + $1.values.reduce(0, +) }
    ShowYearList(
      decadesMap: decadesMap,
      summary: .shows(
        count: shows, years: years,
        stats: Stats(
          statisticsData: model.filteredStatisticsData(
            nearbyModel, distanceThreshold: nearbyDistance)))
    )
    .nearbyLocation(filteredDataIsEmpty: decadesMap.isEmpty)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  ShowsSummary()
}
