//
//  Calendar+Archive.swift
//  SiteApp
//

import Foundation

extension Calendar {
  /// The calendar the archive's dates are in: Gregorian, whatever calendar the person uses, and in
  /// the time zone they are in, so a date made from one and read back is the same date.
  public static let archive: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .autoupdatingCurrent
    return calendar
  }()
}

extension FormatStyle where Self == Date.FormatStyle {
  /// `.dateTime` for a date of the archive, which is written in the Gregorian calendar.
  package static var archiveDateTime: Self { Date.FormatStyle(calendar: .archive) }
}
