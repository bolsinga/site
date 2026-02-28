//
//  PerformersView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation
import SwiftUI

struct PerformersView: View {
  let performers: [String]

  private var headliner: String { performers[0] }
  private var support: [String] { Array(performers.dropFirst()) }

  var body: some View {
    VStack(alignment: .leading) {
      Text(headliner).font(.headline)
      ForEach(support, id: \.self) {
        Text($0)
      }
    }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  PerformersView(performers: model.previewConcert("sh1").performers)
}
