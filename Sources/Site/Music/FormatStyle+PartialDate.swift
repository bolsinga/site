//
//  FormatStyle+PartialDate.swift
//
//
//  Created by Greg Bolsinga on 4/8/23.
//

import Foundation

extension PartialDate {
  struct FormatStyle: Codable, Equatable, Hashable {
    enum Style: Codable, Equatable, Hashable {
      case compact  // 03/03/2023 - Date Unknown
      case yearOnly  // 2023 - Year Unknown
    }

    let style: Style

    public init(_ style: Style = .compact) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension PartialDate.FormatStyle: Foundation.FormatStyle {
  func format(_ value: PartialDate) -> String {
    if !value.isUnknown, let date = value.date {
      var fmt = Date.FormatStyle.dateTime
      switch style {
      case .compact:
        if value.year != nil {
          fmt = fmt.year()
        }
        if value.month != nil {
          fmt = fmt.month(.defaultDigits)
        }
        if value.day != nil {
          fmt = fmt.day()
        }
      case .yearOnly:
        if value.year != nil {
          fmt = fmt.year()
        }
      }
      return fmt.format(date)
    } else {
      if case .yearOnly = style {
        return String(
          localized: "Year Unknown",
          bundle: .module,
          comment:
            "String for when a Show.PartialDate is unknown, and only the year is being shown.")
      }
      return String(
        localized: "Date Unknown",
        bundle: .module,
        comment: "String for when a Show.PartialDate is unknown.")
    }
  }
}

extension PartialDate {
  func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == PartialDate {
    style.format(self)
  }
}

extension FormatStyle where Self == PartialDate.FormatStyle {
  static var compact: Self { .init(.compact) }
  static var yearOnly: Self { .init(.yearOnly) }

  static func partialDate(style: PartialDate.FormatStyle.Style = .compact) -> Self {
    .init(style)
  }
}
