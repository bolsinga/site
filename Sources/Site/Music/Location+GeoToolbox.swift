//
//  Location+GeoToolbox.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/2/25.
//

import GeoToolbox

extension Location {
  var placeRepresentations: [PlaceDescriptor.PlaceRepresentation] {
    [.address(addressString)]
  }
}
