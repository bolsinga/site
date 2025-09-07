//
//  Rank+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/26/23.
//

import Foundation

extension Rank {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case hash  // #1
      case dotted  // 1.
    }

    let style: Style

    public init(_ style: Style = .hash) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Rank.FormatStyle: Foundation.FormatStyle {
  private var unknownLocalized: String {
    return String(localized: "Rank Unknown", bundle: .module)
  }

  public func format(_ value: Rank) -> String {
    switch value {
    case .rank(let rank):
      switch style {
      case .hash:
        return String(
          localized: "#\(rank.formatted(.number.grouping(.never)))", bundle: .module,
          comment: "rank.hash")
      case .dotted:
        return String(
          localized: "\(rank.formatted(.number.grouping(.never))).", bundle: .module,
          comment: "rank.dotted")
      }
    case .unknown:
      return unknownLocalized
    }
  }
}

extension Rank {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Rank {
    style.format(self)
  }
}

extension FormatStyle where Self == Rank.FormatStyle {
  public static var hash: Self { .init(.hash) }
  public static var dotted: Self { .init(.dotted) }

  static func rank(style: Rank.FormatStyle.Style = .hash) -> Self {
    .init(style)
  }
}
