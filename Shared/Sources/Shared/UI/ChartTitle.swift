//
//  ChartTitle.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/4/25.
//

import SwiftUI

public struct ChartTitle: View {
  public enum Alignment: Sendable {
    case `default`
    case center
  }

  let title: LocalizedStringResource
  let alignment: Alignment

  public init(title: LocalizedStringResource, alignment: Alignment) {
    self.title = title
    self.alignment = alignment
  }

  @ViewBuilder private var titleText: some View {
    Text(title)
      .font(.title2).fontWeight(.bold)
  }

  public var body: some View {
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
