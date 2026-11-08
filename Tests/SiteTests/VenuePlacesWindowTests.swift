//
//  VenuePlacesWindowTests.swift
//
//
//  Created by Greg Bolsinga on 11/8/26.
//

import CoreGraphics
import Testing

@testable import SiteApp

struct VenuePlacesWindowTests {
  @Test func defaultSizeIsCenteredOnALargeDisplay() {
    let display = CGRect(x: 0, y: 25, width: 2560, height: 1415)
    let frame = VenuePlaces.defaultWindowPlacement(in: display)
    #expect(frame.size == VenuePlaces.defaultWindowSize)
    #expect(frame.midX == display.midX)
    #expect(frame.midY == display.midY)
  }

  @Test func staysOnASmallDisplay() {
    let display = CGRect(x: 0, y: 25, width: 1024, height: 743)
    let frame = VenuePlaces.defaultWindowPlacement(in: display)
    #expect(display.contains(frame))
    #expect(frame.size == display.size)
  }
}
