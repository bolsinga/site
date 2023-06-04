//
//  LibrarySection+Section.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import SwiftUI

extension LibrarySection {
  @ViewBuilder var representingView: some View {
    switch self {
    case .alphabetic(_), .numeric, .punctuation:
      Text(self.formatted(.long))
    case .ranking(let ranking):
      HStack {
        Text(ranking.formatted(.rankOnly))
        Spacer()
        Text("\(ranking.value) Show(s)", bundle: .module, comment: "LibrarySection.ranking count.")
      }
    }
  }
}

extension LibrarySection {
  var ranking: Ranking {
    if case .ranking(let ranking) = self {
      return ranking
    }
    return Ranking.empty
  }
}
