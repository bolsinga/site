//
//  Decade+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 5/26/23.
//

import Foundation

extension Decade {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case twoDigits  // 80’s
      case defaultDigits  // 1980s
    }

    let style: Style

    public init(_ style: Style = .defaultDigits) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Decade.FormatStyle: Foundation.FormatStyle {
  private var unknown: String {
    return String(localized: "Decade Unknown")
  }

  public func format(_ value: Decade) -> String {
    switch value {
    case .decade(let year):
      guard let date = PartialDate(year: year).date else { return unknown }
      switch style {
      case .twoDigits:
        return String(
          localized: "\(Date.FormatStyle.dateTime.year(.twoDigits).format(date))’s",
          comment: "twoDigits"
        )
      case .defaultDigits:
        return String(
          localized: "\(Date.FormatStyle.dateTime.year(.defaultDigits).format(date))s",
          comment: "defaultDigits")
      }
    case .unknown:
      return unknown
    }
  }
}

extension Decade {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Decade {
    style.format(self)
  }
}

extension FormatStyle where Self == Decade.FormatStyle {
  public static var twoDigits: Self { .init(.twoDigits) }
  public static var defaultDigits: Self { .init(.defaultDigits) }

  static func decade(style: Decade.FormatStyle.Style = .defaultDigits) -> Self {
    .init(style)
  }
}
