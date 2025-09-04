//
//  DecadeFormatTests.swift
//
//
//  Created by Greg Bolsinga on 5/26/23.
//

import MusicData
import Testing

@testable import Site

struct DecadeFormatTests {
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
