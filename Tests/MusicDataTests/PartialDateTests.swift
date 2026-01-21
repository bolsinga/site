//
//  PartialDateTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import Testing

@testable import SiteApp

struct PartialDateTests {
  @Test func unknown_Unknown() {
    let unknown1 = PartialDate()
    let unknown2 = PartialDate()

    #expect(unknown1 == unknown2)
    #expect(!(unknown1 < unknown2))
    #expect(!(unknown2 < unknown1))
  }

  @Test func unknown_YearOnly() {
    let unknown = PartialDate()
    let yearOnly = PartialDate(year: 1997)

    #expect(unknown != yearOnly)
    #expect(unknown < yearOnly)
    #expect(!(yearOnly < unknown))
  }

  @Test func unknown_fullDate() {
    let unknown = PartialDate()
    let date = PartialDate(year: 1970, month: 10, day: 31)

    #expect(unknown != date)
    #expect(unknown < date)
    #expect(!(date < unknown))
  }

  @Test func yearOnly_YearOnly_sameYear() {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1997)

    #expect(date1 == date2)
    #expect(!(date1 < date2))
    #expect(!(date2 < date1))
  }

  @Test func yearOnly_YearOnly_differentYear() {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1998)

    #expect(date1 != date2)
    #expect(date1 < date2)
    #expect(!(date2 < date1))
  }

  @Test func yearOnly_fullDate_sameYear() {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1997, month: 12, day: 31)

    #expect(date1 != date2)
    #expect(date1 < date2)
    #expect(!(date2 < date1))
  }

  @Test func yearOnly_fullDate_nextYear() {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1998, month: 12, day: 31)

    #expect(date1 != date2)
    #expect(date1 < date2)
    #expect(!(date2 < date1))
  }

  @Test func yearOnly_fullDate_previousYear() {
    let date1 = PartialDate(year: 1997)
    let date2 = PartialDate(year: 1996, month: 12, day: 31)

    #expect(date1 != date2)
    #expect(!(date1 < date2))
    #expect(date2 < date1)
  }

  @Test func fullDate_FullDate() {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1996, month: 12, day: 31)

    #expect(date1 != date2)
    #expect(date1 < date2)
    #expect(!(date2 < date1))
  }

  @Test func fullDate_FullDate_same() {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1995, month: 12, day: 31)

    #expect(date1 == date2)
    #expect(!(date1 < date2))
    #expect(!(date2 < date1))
  }

  @Test func spans() {
    let date1 = PartialDate(year: 1995, month: 12, day: 31)
    let date2 = PartialDate(year: 1997)
    let unknownDate = PartialDate()

    #expect(Set([date1]).yearSpan == 1)
    #expect(Set([date2]).yearSpan == 1)
    #expect(Set([unknownDate]).yearSpan == 1)

    #expect(Set([date1, date2]).yearSpan == 2)
    #expect(Set([date1, date1]).yearSpan == 1)
    #expect(Set([date2, date2]).yearSpan == 1)

    #expect(Set([unknownDate, unknownDate]).yearSpan == 1)
    #expect(Set([unknownDate, date1]).yearSpan == 1)
    #expect(Set([unknownDate, date1, date2]).yearSpan == 2)

    #expect(Set<PartialDate>().yearSpan == 0)

    let unwoundDate = PartialDate(year: 1995, month: 4, day: 1)
    let unwoundDate28YearsAgo = PartialDate(year: 2023, month: 5, day: 26)
    #expect(Set([unwoundDate, unwoundDate28YearsAgo]).yearSpan == 28)

    let unwoundLast = PartialDate(year: 2023, month: 2, day: 8)
    #expect(Set([unwoundDate, unwoundLast]).yearSpan == 27)

    let miloFirst = PartialDate(year: 1993, month: 2, day: 13)
    let miloLast = PartialDate(year: 1994, month: 5, day: 13)
    #expect(Set([miloFirst, miloLast]).yearSpan == 2)

    let jumpknuckleFirst = PartialDate(year: 1993, month: 2, day: 13)
    let jumpknuckleLast = PartialDate(year: 1994, month: 12, day: 28)
    #expect(Set([jumpknuckleFirst, jumpknuckleLast]).yearSpan == 2)

    let posterchildrenFirst = PartialDate(year: 1989, month: 1, day: 17)
    let posterchildrenLast = PartialDate(year: 2016, month: 10, day: 16)
    #expect(Set([unknownDate, posterchildrenFirst, posterchildrenLast]).yearSpan == 27)

    let humFirst = PartialDate(year: 1991, month: 11, day: 23)
    let humLast = PartialDate(year: 2015, month: 9, day: 18)
    #expect(Set([humFirst, humLast]).yearSpan == 23)

    let initialDate = PartialDate(year: 2023, month: 2, day: 6)
    let nextDay = PartialDate(year: 2023, month: 2, day: 7)
    let nextMonth = PartialDate(year: 2023, month: 3, day: 1)
    let nextMonthToTheDay = PartialDate(year: 2023, month: 3, day: 6)
    let almostNextYear = PartialDate(year: 2023, month: 12, day: 15)
    let yearJustChanged = PartialDate(year: 2024, month: 1, day: 1)
    let almostAYearLater = PartialDate(year: 2024, month: 2, day: 5)
    let oneYearToTheDayLater = PartialDate(year: 2024, month: 2, day: 6)
    let oneYearAndOneDayLater = PartialDate(year: 2024, month: 2, day: 7)
    let twoYearsToTheDayLater = PartialDate(year: 2025, month: 2, day: 6)
    let twoYearsAndOneDayLater = PartialDate(year: 2025, month: 2, day: 7)
    let threeYearsToTheDayLater = PartialDate(year: 2026, month: 2, day: 6)
    let threeYearsAndOneDayLater = PartialDate(year: 2026, month: 2, day: 7)

    #expect(Set([initialDate, nextDay]).yearSpan == 1)
    #expect(Set([initialDate, nextMonth]).yearSpan == 1)
    #expect(Set([initialDate, nextMonthToTheDay]).yearSpan == 1)
    #expect(Set([initialDate, almostNextYear]).yearSpan == 1)
    #expect(Set([initialDate, yearJustChanged]).yearSpan == 1)
    #expect(Set([initialDate, almostAYearLater]).yearSpan == 1)
    #expect(Set([initialDate, oneYearToTheDayLater]).yearSpan == 1)
    #expect(Set([initialDate, oneYearAndOneDayLater]).yearSpan == 2)
    #expect(Set([initialDate, twoYearsToTheDayLater]).yearSpan == 2)
    #expect(Set([initialDate, twoYearsAndOneDayLater]).yearSpan == 2)
    #expect(Set([initialDate, threeYearsToTheDayLater]).yearSpan == 3)
    #expect(Set([initialDate, threeYearsAndOneDayLater]).yearSpan == 3)
  }
}
