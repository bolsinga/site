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
      .locationFilter(nearbyModel, filteredDataIsEmpty: decadesMap.isEmpty)
  }
}

#Preview {
  let vaultModel = VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  return ShowsSummary(model: vaultModel, nearbyModel: NearbyModel(vaultModel: vaultModel))
}
