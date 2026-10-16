//
//  Location+GeoToolbox.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/2/25.
//

import GeoToolbox
import Shared

extension Location {
  var placeRepresentations: [PlaceDescriptor.PlaceRepresentation] {
    [.address(addressString)]
  }
}
