//
//  Venue+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 8/29/23.
//

import Foundation
import MusicData

extension Venue {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case oneLine
    }

    let style: Style

    public init(_ style: Style = .oneLine) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Venue.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Venue) -> String {
    switch style {
    case .oneLine:
      var result = "[\(value.id)] \(value.name)"

      if let sortname = value.sortname {
        result += " (\(sortname)"
      }

      return "\(result), \(value.location.formatted(.oneLine))"
    }
  }
}

extension Venue {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Venue {
    style.format(self)
  }
}

extension FormatStyle where Self == Venue.FormatStyle {
  public static var oneLine: Self { .init(.oneLine) }

  static func Venue(style: Venue.FormatStyle.Style = .oneLine) -> Self {
    .init(style)
  }
}
