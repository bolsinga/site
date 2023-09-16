//
//  NearbyLabel.swift
//
//
//  Created by Greg Bolsinga on 9/16/23.
//

import SwiftUI

struct NearbyLabel: View {
  @Binding var nearbyConcertCount: Int
  @Binding var geocodingProgress: Double

  var body: some View {
    Label {
      Text(nearbyConcertCount.formatted(.number))
        .animation(.easeInOut)
    } icon: {
      if geocodingProgress < 1.0 {
        ProgressView(value: geocodingProgress)
          .progressViewStyle(.circular)
          .tint(.accentColor)
          #if os(macOS)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
          #endif
      }
    }
  }
}

struct NearbyLabel_Previews: PreviewProvider {
  static var previews: some View {
    NearbyLabel(nearbyConcertCount: .constant(10), geocodingProgress: .constant(0.0))

    NearbyLabel(nearbyConcertCount: .constant(10), geocodingProgress: .constant(0.5))

    NearbyLabel(nearbyConcertCount: .constant(10), geocodingProgress: .constant(1.0))
  }
}
