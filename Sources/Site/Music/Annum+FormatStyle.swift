//
//  Annum+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/9/23.
//

import Foundation

extension Annum {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case year  // 1989 / "Year Unknown"
      case json  // 1989 / unknown
    }

    let style: Style

    public init(_ style: Style = .year) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Annum.FormatStyle: Foundation.FormatStyle {
  private var unknownLocalized: String {
    return String(
      localized: "Year Unknown", bundle: .module, comment: "String for when a Annum is unknown.")
  }

  static let unknown = "unknown"

  public func format(_ value: Annum) -> String {
    switch value {
    case .year(let year):
      guard let date = PartialDate(year: year).date else { return unknownLocalized }
      return Date.FormatStyle.dateTime.year(.defaultDigits).format(date)
    case .unknown:
      switch style {
      case .year:
        return unknownLocalized
      case .json:
        return Annum.FormatStyle.unknown
      }
    }
  }
}

extension Annum {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Annum {
    style.format(self)
  }
}

extension FormatStyle where Self == Annum.FormatStyle {
  public static var year: Self { .init(.year) }
  public static var json: Self { .init(.json) }

  static func annum(style: Annum.FormatStyle.Style = .year) -> Self {
    .init(style)
  }
}
