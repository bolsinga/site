//
//  PartialDate+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 4/8/23.
//

import Foundation

extension PartialDate {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case compact  // 03/03/2023 - Date Unknown
      case noYear  // March 3
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
  public func format(_ value: PartialDate) -> String {
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
      case .noYear:
        if value.month != nil {
          fmt = fmt.month(.wide)
        }
        if value.day != nil {
          fmt = fmt.day()
        }
        if value.month == nil && value.day == nil {
          fmt = fmt.year()  // Still show year if other parts are unknown.
        }
      case .yearOnly:
        if value.year != nil {
          fmt = fmt.year()
        }
      }
      return fmt.format(date)
    } else {
      if case .yearOnly = style {
        return String(localized: "Year Unknown", bundle: .module)
      }
      return String(localized: "Date Unknown", bundle: .module)
    }
  }
}

extension PartialDate {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == PartialDate {
    style.format(self)
  }
}

extension FormatStyle where Self == PartialDate.FormatStyle {
  public static var compact: Self { .init(.compact) }
  public static var noYear: Self { .init(.noYear) }
  public static var yearOnly: Self { .init(.yearOnly) }

  static func partialDate(style: PartialDate.FormatStyle.Style = .compact) -> Self {
    .init(style)
  }
}
