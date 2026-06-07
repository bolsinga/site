//
//  MapItem+Geometry.swift
//
//
//  Created by Greg Bolsinga on 5/31/23.
//

import MapKit

extension MKMapRect {
  fileprivate var centerPoint: MKMapPoint {
    MKMapPoint(x: midX, y: midY)
  }

  fileprivate var centerCoordinate: CLLocationCoordinate2D {
    centerPoint.coordinate
  }

  fileprivate func padded(_ distance: CLLocationDistance = 100.0) -> MKMapRect {
    let mapPointOffset = MKMapPointsPerMeterAtLatitude(centerCoordinate.latitude) * distance / 2.0

    return insetBy(dx: -mapPointOffset, dy: -mapPointOffset)
  }

  var proportionallyPadded: MKMapRect {
    let midY = (maxY + minY) / 2.0

    let midLeft = MKMapPoint(x: minX, y: midY)
    let midRight = MKMapPoint(x: maxX, y: midY)

    let widthInMeters = midLeft.distance(to: midRight)

    if widthInMeters < 100.0 {
      return padded()
    }

    return padded(widthInMeters * 0.1)
  }

  fileprivate var topLeft: MKMapPoint {
    MKMapPoint(x: minX, y: maxY)
  }

  fileprivate var topRight: MKMapPoint {
    MKMapPoint(x: maxX, y: maxY)
  }

  fileprivate var bottomRight: MKMapPoint {
    MKMapPoint(x: maxX, y: minY)
  }

  fileprivate var bottomLeft: MKMapPoint {
    MKMapPoint(x: minX, y: minY)
  }

  var corners: [MKMapPoint] {
    [topLeft, topRight, bottomRight, bottomLeft]
  }
}

extension MKMapItem {
  fileprivate var center: CLLocationCoordinate2D {
    self.location.coordinate
  }

  var rect: MKMapRect {
    let centerCoordinate = center
    guard CLLocationCoordinate2DIsValid(centerCoordinate) else { return .null }

    let unitSize = MKMapSize(width: 1.0, height: 1.0)
    let centerPoint = MKMapPoint(centerCoordinate)
    let originPoint = MKMapPoint(
      x: centerPoint.x - unitSize.width / 2.0, y: centerPoint.y - unitSize.height / 2.0)
    return MKMapRect(origin: originPoint, size: unitSize)
  }
}

extension Collection where Element == MKMapItem {
  var rect: MKMapRect {
    reduce(into: MKMapRect.null) { $0 = $0.union($1.rect) }
  }
}
