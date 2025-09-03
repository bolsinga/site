//
//  PartialDateFormatTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import MusicData
import Testing

@testable import Site

struct PartialDateFormatTests {
  @Test func format() {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1997)
    let unknownDate = PartialDate()

    #expect(date1.formatted() == "12/31/1995")
    #expect(date2.formatted() == "1997")
    #expect(unknownDate.formatted() == "Date Unknown")

    #expect(date1.formatted(.compact) == "12/31/1995")
    #expect(date2.formatted(.compact) == "1997")
    #expect(unknownDate.formatted(.compact) == "Date Unknown")

    #expect(date1.formatted(.yearOnly) == "1995")
    #expect(date2.formatted(.yearOnly) == "1997")
    #expect(unknownDate.formatted(.yearOnly) == "Year Unknown")

    #expect(date1.formatted(.noYear) == "December 31")
    #expect(date2.formatted(.noYear) == "1997")
    #expect(unknownDate.formatted(.noYear) == "Date Unknown")
  }
}
