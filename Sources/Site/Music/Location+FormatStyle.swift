//
//  Location+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 8/29/23.
//

import Foundation
import MusicData

extension Location {
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

extension Location.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Location) -> String {
    switch style {
    case .oneLine:
      var physicalAddress: String = ""
      if let street = value.street {
        physicalAddress = "\(street), "
      }

      physicalAddress += "\(value.city), \(value.state)"

      if let url = value.web {
        return "\(physicalAddress) [\(url)]"
      }
      return physicalAddress
    }
  }
}

extension Location {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Location {
    style.format(self)
  }
}

extension FormatStyle where Self == Location.FormatStyle {
  public static var oneLine: Self { .init(.oneLine) }

  static func Location(style: Location.FormatStyle.Style = .oneLine) -> Self {
    .init(style)
  }
}
