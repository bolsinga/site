//
//  Venue+GeoToolbox.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/2/25.
//

import GeoToolbox

extension Venue {
  @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
  var placeDescriptor: PlaceDescriptor {
    PlaceDescriptor(representations: location.placeRepresentations, commonName: name)
  }
}
