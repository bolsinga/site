//
//  LaunchModeTests.swift
//  site
//
//  Created by Greg Bolsinga on 11/23/26.
//

import Testing

@testable import SiteApp

struct LaunchModeTests {
  @Test func theKeyMakesTheLaunchQuiet() {
    #expect(LaunchMode(environment: [LaunchMode.quietKey: "1"]) == .quiet)
  }

  @Test func withoutTheKeyTheLaunchIsNormal() {
    #expect(LaunchMode(environment: [:]) == .normal)
  }

  @Test(arguments: ["0", "", "true", "yes"])
  func anyOtherValueIsNormal(value: String) {
    #expect(LaunchMode(environment: [LaunchMode.quietKey: value]) == .normal)
  }

  /// The scheme's test action sets the key. A test run without it starts the app's own work.
  @Test func theHostOfTheseTestsIsQuiet() {
    #expect(LaunchMode() == .quiet)
  }
}
