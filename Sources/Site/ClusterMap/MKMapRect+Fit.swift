//
//  MKMapRect+Fit.swift
//  site
//

import MapKit

extension MKMapRect {
  /// How much of the top inset, the bars, items may spill into above and below the clear area.
  private static var spillFraction: CGFloat { 0.45 }

  func zoomedOut(by factor: Double) -> MKMapRect {
    guard factor > 1.0 else { return self }
    return MKMapRect(
      x: midX - width * factor / 2.0, y: midY - height * factor / 2.0,
      width: width * factor, height: height * factor)
  }

  /// The rect of a map of `size` that has this rect centered in the area the insets leave clear.
  /// A fading map also lets items spill into the bars and the fade, and keeps the middle of the map.
  func fitted(
    in size: CGSize, top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat,
    fades: Bool
  ) -> MKMapRect? {
    let areaWidth = size.width - leading - trailing
    let areaHeight = size.height - top - bottom
    guard areaWidth > 0, areaHeight > 0, width > 0, height > 0 else { return nil }
    // The area is a thin band between the bars and the fade. Items spread far north to south
    // can spill a little into both, so size the zoom to a taller area around the same center.
    let spill = fades ? top * Self.spillFraction : 0
    let mapPointsPerPoint = max(width / areaWidth, height / (areaHeight + spill * 2.0))
    // The middle of the map, unless the bars leave less room above it than the fade does below.
    let centerY = fades ? max(size.height / 2.0, top + areaHeight / 2.0) : top + areaHeight / 2.0
    return MKMapRect(
      x: midX - (leading + areaWidth / 2.0) * mapPointsPerPoint,
      y: midY - centerY * mapPointsPerPoint,
      width: size.width * mapPointsPerPoint, height: size.height * mapPointsPerPoint)
  }
}
