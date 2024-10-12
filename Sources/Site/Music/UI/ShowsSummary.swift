//
//  ShowsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct ShowsSummary: View {
  let model: VaultModel
  let nearbyModel: NearbyModel

  var body: some View {
    let decadesMap = model.filteredDecadesMap(nearbyModel)
    ShowYearList(decadesMap: decadesMap)
      .nearbyLocation(
        locationFilter: nearbyModel.locationFilter,
        locationAuthorization: model.locationAuthorization,
        geocodingProgress: model.geocodingProgress, filteredDataIsEmpty: decadesMap.isEmpty
      )
  }
}

#Preview {
  ShowsSummary(
    model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false), nearbyModel: NearbyModel()
  )
}
