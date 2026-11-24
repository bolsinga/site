//
//  Annum+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/9/23.
//

import Foundation

extension Annum {
  package struct FormatStyle: Codable, Equatable, Hashable {
    package enum Style: Codable, Equatable, Hashable {
      case year  // 1989 / "Year Unknown"
      case json  // 1989 / unknown
      case urlPath  // 1989 / other
      case shared  // "Shows from 1989" / "Shows from Unknown Years"
    }

    let style: Style

    public init(_ style: Style = .year) {
      self.style = style
    }

    package func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Annum.FormatStyle: Foundation.FormatStyle {
  private var unknownLocalized: String {
    return String(localized: "Year Unknown", bundle: #bundle)
  }

  private var sharedUnknownLocalized: String {
    return String(localized: "Shows from Unknown Years", bundle: #bundle)
  }

  static let unknown = "unknown"
  static let other = "other"

  package func format(_ value: Annum) -> String {
    switch value {
    case .year(let year):
      guard let date = PartialDate(year: year).date else { return unknownLocalized }
      if case .shared = self {
        return String(
          localized:
            "Shows from \(Date.FormatStyle.archiveDateTime.year(.defaultDigits).format(date))",
          bundle: #bundle)
      } else {
        return Date.FormatStyle.archiveDateTime.year(.defaultDigits).format(date)
      }
    case .unknown:
      switch style {
      case .year:
        return unknownLocalized
      case .json:
        return Annum.FormatStyle.unknown
      case .urlPath:
        return Annum.FormatStyle.other
      case .shared:
        return sharedUnknownLocalized
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
  package static var year: Self { .init(.year) }
  package static var json: Self { .init(.json) }
  package static var urlPath: Self { .init(.urlPath) }
  package static var shared: Self { .init(.shared) }

  static func annum(style: Annum.FormatStyle.Style = .year) -> Self {
    .init(style)
  }
}
