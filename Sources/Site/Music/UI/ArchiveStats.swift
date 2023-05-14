//
//  ArchiveStats.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import SwiftUI

struct ArchiveStats: View {
  let shows: [Show]

  var body: some View {
    ScrollView {
      Stats(shows: shows)
    }
    .navigationTitle(Text(ArchiveCategory.stats.localizedString))
  }
}
