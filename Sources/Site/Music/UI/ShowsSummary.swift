//
//  ShowsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import CoreLocation
import Shared
import SiteCore
import SwiftUI

struct ShowsSummary: View {
  @Environment(VaultModel.self) var model
  @Environment(NearbyModel.self) var nearbyModel
  @NearbyDistanceStorage private var nearbyDistance

  @Binding var descending: Bool

  var body: some View {
    let decadesMap = model.filteredDecadesMap(nearbyModel, distanceThreshold: nearbyDistance)
    let years = decadesMap.values.reduce(0) { $0 + $1.count }
    let shows = decadesMap.values.reduce(0) { $0 + $1.values.reduce(0, +) }
    ShowYearList(
      decadesMap: decadesMap,
      summary: decadesMap.isEmpty
        ? nil
        : .shows(
          count: shows, years: years,
          stats: Stats(
            statisticsData: model.filteredStatisticsData(
              nearbyModel, distanceThreshold: nearbyDistance))),
      descending: $descending
    )
    .nearbyLocation(filteredDataIsEmpty: decadesMap.isEmpty)
  }
}

#Preview(traits: .nearbyModel, .vaultModel) {
  ShowsSummary(descending: .constant(false))
}
