//
//  Rank+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/26/23.
//

import Foundation

extension Rank {
  package struct FormatStyle: Codable, Equatable, Hashable {
    package enum Style: Codable, Equatable, Hashable {
      case hash  // #1
      case dotted  // 1.
    }

    package let style: Style

    package init(_ style: Style = .hash) {
      self.style = style
    }

    package func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Rank.FormatStyle: Foundation.FormatStyle {
  private var unknownLocalized: String {
    return String(localized: "Rank Unknown", bundle: #bundle)
  }

  package func format(_ value: Rank) -> String {
    switch value {
    case .rank(let rank):
      switch style {
      case .hash:
        return String(
          localized: "#\(rank.formatted(.number.grouping(.never)))", bundle: #bundle,
          comment: "rank.hash")
      case .dotted:
        return String(
          localized: "\(rank.formatted(.number.grouping(.never))).", bundle: #bundle,
          comment: "rank.dotted")
      }
    case .unknown:
      return unknownLocalized
    }
  }
}

extension Rank {
  package func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  package func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Rank {
    style.format(self)
  }
}

extension FormatStyle where Self == Rank.FormatStyle {
  package static var hash: Self { .init(.hash) }
  package static var dotted: Self { .init(.dotted) }

  package static func rank(style: Rank.FormatStyle.Style = .hash) -> Self {
    .init(style)
  }
}
