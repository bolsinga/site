//
//  Venue+GeoToolbox.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/2/25.
//

import GeoToolbox

extension Venue {
  package var placeDescriptor: PlaceDescriptor {
    PlaceDescriptor(representations: location.placeRepresentations, commonName: name)
  }
}
