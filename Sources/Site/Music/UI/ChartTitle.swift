//
//  ChartTitle.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/4/25.
//

import SwiftUI

struct ChartTitle: View {
  enum Alignment {
    case `default`
    case center
  }

  let title: LocalizedStringResource
  let alignment: Alignment

  @ViewBuilder private var titleText: some View {
    Text(title)
      .font(.title2).fontWeight(.bold)
  }

  var body: some View {
    switch alignment {
    case .default:
      titleText
    case .center:
      HStack {
        Spacer()
        titleText
        Spacer()
      }
    }
  }
}

#Preview("Default") {
  ChartTitle(title: "Title", alignment: .default)
}

#Preview("Center") {
  ChartTitle(title: "Title", alignment: .center)
}
