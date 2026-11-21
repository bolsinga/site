//
//  SampleMusicTests.swift
//  site
//
//  Created by Greg Bolsinga on 11/20/26.
//

import Foundation
import Testing

@testable import Shared
@testable import SiteApp

struct SampleMusicTests {
  @MainActor @Test func theSampleLoadsWithoutTheNetwork() async throws {
    let model = try await VaultModel.sample()

    #expect(model.vault.showIDs().count == 20)
  }

  @MainActor @Test func thePreviewsFindWhatTheyShow() async throws {
    let model = try await VaultModel.sample()

    for id in ["sh1", "sh100", "sh500", "sh899"] {
      #expect(model.vault.digest(show: .show(id)) != nil, "\(id)")
    }
    for id in ["v0", "v103"] {
      #expect(model.vault.digest(venue: .venue(id)) != nil, "\(id)")
    }
    #expect(model.vault.digest(artist: .artist("ar692")) != nil)
    for year in [2000, 2001, 2002] {
      #expect(model.vault.digest(annum: .year(year)) != nil, "\(year)")
    }
  }
}
