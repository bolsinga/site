//
//  CityFilterView.swift
//  site
//
//  Created by Greg Bolsinga on 10/29/26.
//

import SwiftUI

/// Explains an empty City filter: no city is known, or no venue is in it.
struct CityFilterView: View {
  let city: String?
  let filteredDataIsEmpty: Bool

  /// Shown over a map, instead of an empty background.
  let overMap: Bool

  var body: some View {
    if let city {
      if filteredDataIsEmpty {
        ContentUnavailableView(
          String(localized: "Nothing in \(city)"),
          systemImage: "building.2.crop.circle",
          description: Text(
            "No venues are in this city. Disable the Location Filter or edit the city.")
        )
        .modifier(MapCardModifier(enabled: overMap))
      }
    } else {
      ContentUnavailableView(
        String(localized: "No City"),
        systemImage: "building.2.crop.circle",
        description: Text("No city. Allow location or enter a city.")
      )
      .modifier(MapCardModifier(enabled: overMap))
    }
  }
}

#Preview("No City") {
  CityFilterView(city: nil, filteredDataIsEmpty: true, overMap: false)
}

#Preview("Nothing In City") {
  CityFilterView(city: "Denver", filteredDataIsEmpty: true, overMap: false)
}
