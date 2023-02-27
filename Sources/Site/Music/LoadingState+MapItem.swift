//
//  LoadingState+MapItem.swift
//
//
//  Created by Greg Bolsinga on 2/27/23.
//

import Contacts
import Foundation
import LoadingState
import MapKit

private enum MapItemLoadingError: Error {
  case noPlacemark
}

extension LoadingState where Value == MKMapItem {
  public mutating func geocode(location: Location) async {
    guard case .idle = self else {
      return
    }

    self = .loading

    do {
      let placemarks = try await CLGeocoder().geocodePostalAddress(location.postalAddress)
      if let placemark = placemarks.first {
        self = .loaded(MKMapItem(placemark: MKPlacemark(placemark: placemark)))
      } else {
        throw MapItemLoadingError.noPlacemark
      }
    } catch {
      self = .error(error)
    }
  }
}
