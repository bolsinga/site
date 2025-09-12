//
//  PerformersView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation
import SwiftUI

struct PerformersView: View {
  let concert: Concert

  var body: some View {
    VStack(alignment: .leading) {
      Text(concert.headliner.name).font(.headline)
      ForEach(concert.support) { artist in
        Text(artist.name)
      }
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  PerformersView(concert: model.vault.concerts[0])
}
