//
//  DecadeTests.swift
//
//
//  Created by Greg Bolsinga on 5/26/23.
//

import Testing

@testable import Site

struct DecadeTests {
  @Test func int() {
    #expect(1910.decade == .decade(1910))
    #expect(1911.decade == .decade(1910))
    #expect(1919.decade == .decade(1910))
    #expect(1920.decade == .decade(1920))
    #expect(1921.decade == .decade(1920))
  }

  @Test func partialDate() {
    #expect(PartialDate().decade == Decade.unknown)
    #expect(PartialDate(year: 1910).decade == .decade(1910))
    #expect(PartialDate(year: 1920).decade == .decade(1920))
    #expect(PartialDate(month: 10).decade == Decade.unknown)
    #expect(PartialDate(month: 10, day: 15).decade == Decade.unknown)
    #expect(PartialDate(day: 15).decade == Decade.unknown)
  }

  @Test func formats() {
    #expect(1910.decade.formatted(.defaultDigits) == "1910s")
    #expect(1911.decade.formatted(.defaultDigits) == "1910s")
    #expect(1910.decade.formatted(.twoDigits) == "10’s")
    #expect(1911.decade.formatted(.twoDigits) == "10’s")

    #expect(1990.decade.formatted(.twoDigits) == "90’s")
    #expect(2000.decade.formatted(.twoDigits) == "00’s")
    #expect(2010.decade.formatted(.twoDigits) == "10’s")

    #expect(PartialDate().decade.formatted(.defaultDigits) == "Decade Unknown")
    #expect(PartialDate().decade.formatted(.twoDigits) == "Decade Unknown")
  }
}
