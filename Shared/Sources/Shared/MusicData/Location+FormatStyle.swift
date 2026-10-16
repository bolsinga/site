//
//  Location+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 8/29/23.
//

import Foundation

extension Location {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case oneLine
      case oneLineNoURL
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

extension Location {
  fileprivate var physicalAddress: String {
    var physicalAddress: String = ""
    if let street = street {
      physicalAddress = "\(street), "
    }

    physicalAddress += "\(city), \(state)"
    return physicalAddress
  }
}

extension Location.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Location) -> String {
    switch style {
    case .oneLine:
      let physicalAddress = value.physicalAddress

      if let url = value.web {
        return "\(physicalAddress) [\(url)]"
      }
      return physicalAddress

    case .oneLineNoURL:
      return value.physicalAddress
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
  public static var oneLineNoURL: Self { .init(.oneLineNoURL) }

  static func Location(style: Location.FormatStyle.Style = .oneLine) -> Self {
    .init(style)
  }
}
