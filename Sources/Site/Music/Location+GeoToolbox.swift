//
//  Location+GeoToolbox.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/2/25.
//

import GeoToolbox

extension Location {
  @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
  var placeRepresentations: [PlaceDescriptor.PlaceRepresentation] {
    [.address(addressString)]
  }
}
