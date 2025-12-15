//
//  Venue+GeoToolbox.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/2/25.
//

import GeoToolbox

extension Venue {
  var placeDescriptor: PlaceDescriptor {
    PlaceDescriptor(representations: location.placeRepresentations, commonName: name)
  }
}
