//
//  NearbyList.swift
//
//
//  Created by Greg Bolsinga on 9/14/23.
//

import SwiftUI

struct NearbyList: View {
  let concerts: [Concert]
  @Binding var geocodingProgress: Double

  var body: some View {
    VStack {
      ZStack {
        if concerts.isEmpty {
          Text(
            "No Shows Nearby", bundle: .module,
            comment: "Text shown when there are no nearby concerts."
          )
          .font(.title)
          .foregroundColor(.secondary)
        } else {
          List(concerts) { concert in
            NavigationLink(value: concert) { NearbyBlurb(concert: concert) }
          }
          .listStyle(.plain)
        }
      }
      if geocodingProgress < 1.0 {
        ProgressView(value: geocodingProgress)
          .progressViewStyle(.circular)
          .tint(.accentColor)
          #if os(macOS)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
          #endif
      }
    }
    .navigationTitle(Text("Nearby Shows", bundle: .module, comment: "Nearby Shows Title"))
  }
}

struct NearbyList_Previews: PreviewProvider {
  static var previews: some View {
    let vaultPreview = Vault.previewData

    NavigationStack {
      NearbyList(concerts: vaultPreview.concerts, geocodingProgress: .constant(0.5))
        .musicDestinations(vaultPreview)
    }
  }
}
