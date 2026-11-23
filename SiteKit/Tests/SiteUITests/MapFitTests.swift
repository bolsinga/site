//
//  MapFitTests.swift
//  site
//

import MapKit
import Testing

@testable import SiteCore
@testable import SiteUI

struct MapFitTests {
  private let rect = MKMapRect(x: 1000, y: 2000, width: 100, height: 100)
  private let size = CGSize(width: 200, height: 100)

  private func isClose(_ lhs: Double, _ rhs: Double) -> Bool { abs(lhs - rhs) < 0.0001 }

  @Test func centersTheRectInTheMap() throws {
    let fitted = try #require(
      rect.fitted(in: size, top: 0, leading: 0, bottom: 0, trailing: 0, fades: false))
    #expect(isClose(fitted.midX, rect.midX))
    #expect(isClose(fitted.midY, rect.midY))
    #expect(isClose(fitted.width, 200))
    #expect(isClose(fitted.height, 100))
  }

  @Test func centersTheRectInTheAreaTheInsetsLeaveClear() throws {
    let fitted = try #require(
      rect.fitted(in: size, top: 0, leading: 50, bottom: 0, trailing: 0, fades: false))
    // The clear area is 150 points wide, starting at 50, so its middle is at 125.
    #expect(isClose(fitted.minX + 125, rect.midX))
  }

  @Test func aFadingMapKeepsTheMiddleAndLetsItemsSpill() throws {
    let fading = try #require(
      rect.fitted(in: size, top: 20, leading: 0, bottom: 40, trailing: 0, fades: true))
    let plain = try #require(
      rect.fitted(in: size, top: 20, leading: 0, bottom: 40, trailing: 0, fades: false))
    // The rect's center stays at the middle of the map's height.
    #expect(isClose(fading.minY + fading.height / 2, rect.midY))
    // Spilling into the bars and the fade lets the map show less than the clear area would.
    #expect(fading.width < plain.width)
  }

  @Test func hasNoFitWithoutRoom() {
    #expect(
      rect.fitted(in: size, top: 0, leading: 100, bottom: 0, trailing: 100, fades: false) == nil)
    #expect(rect.fitted(in: size, top: 50, leading: 0, bottom: 50, trailing: 0, fades: true) == nil)
    let empty = MKMapRect(x: 0, y: 0, width: 0, height: 0)
    #expect(empty.fitted(in: size, top: 0, leading: 0, bottom: 0, trailing: 0, fades: false) == nil)
  }

  @Test func zoomsOutAroundTheCenter() {
    let zoomed = rect.zoomedOut(by: 2)
    #expect(isClose(zoomed.midX, rect.midX))
    #expect(isClose(zoomed.midY, rect.midY))
    #expect(isClose(zoomed.width, 200))
    #expect(isClose(zoomed.height, 200))
  }

  @Test func doesNotZoomOutByOneOrLess() {
    #expect(MKMapRectEqualToRect(rect.zoomedOut(by: 1), rect))
    #expect(MKMapRectEqualToRect(rect.zoomedOut(by: 0.5), rect))
  }
}
