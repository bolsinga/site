//
//  PerformersView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation
import SwiftUI

public struct PerformersView: View {
  let performers: [String]

  public init(performers: [String]) {
    self.performers = performers
  }

  private var headliner: String { performers[0] }
  private var support: [String] { Array(performers.dropFirst()) }

  public var body: some View {
    VStack(alignment: .leading) {
      Text(headliner).font(.headline)
      ForEach(support, id: \.self) {
        Text($0)
      }
    }
  }
}

#Preview {
  PerformersView(performers: ["Belle And Sebastian", "The National", "Broken Social Scene"])
}
