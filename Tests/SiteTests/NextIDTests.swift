//
//  NextIDTests.swift
//  site
//
//  Created by Greg Bolsinga on 11/21/26.
//

#if os(macOS)
  import Testing

  @testable import SiteApp

  struct NextIDTests {
    @Test func anEmptyMapStartsAtZero() {
      let ids = [String]()

      #expect(ids.archiveIndices.isEmpty)
      #expect(ids.nextArchiveIndex == 0)
    }

    @Test func idsWithNoGapsContinueTheSequence() {
      let ids = ["ar0", "ar1", "ar2"]

      #expect(ids.archiveIndices.isEmpty)
      #expect(ids.nextArchiveIndex == 3)
    }

    @Test func theSmallestGapIsFilledFirst() {
      let ids = ["sh0", "sh1", "sh3", "sh5"]

      #expect(ids.archiveIndices == [2])
      #expect(ids.nextArchiveIndex == 2)
    }

    @Test func anIdWithNoDigitsHasNoNumberButStillCounts() {
      let ids = ["ar0", "unknown", "ar1"]

      #expect(ids.archiveIndices.isEmpty)
      #expect(ids.nextArchiveIndex == 3)
    }

    @Test func aSingleIdStartingAboveZeroLeavesZero() {
      let ids = ["v7"]

      #expect(ids.nextArchiveIndex == 0)
    }
  }
#endif
