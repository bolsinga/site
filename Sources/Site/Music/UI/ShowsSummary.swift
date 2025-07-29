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

  var body: some View {
    let decadesMap = model.filteredDecadesMap(nearbyModel)
    ShowYearList(decadesMap: decadesMap)
      .nearbyLocation(filteredDataIsEmpty: decadesMap.isEmpty)
  }
}

#Preview {
  ShowsSummary()
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
    .environment(NearbyModel())
}
