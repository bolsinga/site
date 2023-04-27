//
//  Stats.swift
//
//
//  Created by Greg Bolsinga on 4/26/23.
//

import SwiftUI

struct Stats: View {
  var body: some View {
    ScrollView {
      VStack {
        WeekdayChart()
      }
    }
  }
}

struct Stats_Previews: PreviewProvider {
  static var previews: some View {
    Stats()
  }
}
