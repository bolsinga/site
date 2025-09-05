//
//  Annum+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/9/23.
//

import Foundation
import MusicData

extension Annum {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case year  // 1989 / "Year Unknown"
      case json  // 1989 / unknown
      case urlPath  // 1989 / other
      case shared  // "Shows from 1989" / "Shows from Unknown Years"
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
    return String(localized: "Year Unknown", bundle: .module)
  }

  private var sharedUnknownLocalized: String {
    return String(localized: "Shows from Unknown Years", bundle: .module)
  }

  static let unknown = "unknown"
  static let other = "other"

  public func format(_ value: Annum) -> String {
    switch value {
    case .year(let year):
      guard let date = PartialDate(year: year).date else { return unknownLocalized }
      if case .shared = self {
        return String(
          localized: "Shows from \(Date.FormatStyle.dateTime.year(.defaultDigits).format(date))",
          bundle: .module)
      } else {
        return Date.FormatStyle.dateTime.year(.defaultDigits).format(date)
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
  public static var year: Self { .init(.year) }
  public static var json: Self { .init(.json) }
  public static var urlPath: Self { .init(.urlPath) }
  public static var shared: Self { .init(.shared) }

  static func annum(style: Annum.FormatStyle.Style = .year) -> Self {
    .init(style)
  }
}
