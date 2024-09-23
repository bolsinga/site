//
//  TodaySummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct TodaySummary: View {
  let model: VaultModel
  var body: some View {
    TodayList(concerts: model.todayConcerts)
  }
}

#Preview {
  TodaySummary(model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
