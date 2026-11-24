//
//  FormatStyle+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Ranking {
  package struct FormatStyle: Codable, Equatable, Hashable {
    package enum Style: Codable, Equatable, Hashable {
      case rankOnly
      case rankAndCount
    }

    package let style: Style

    package init(_ style: Style = .rankOnly) {
      self.style = style
    }

    package func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Ranking.FormatStyle: Foundation.FormatStyle {
  package func format(_ value: Ranking) -> String {
    switch style {
    case .rankOnly:
      return value.rank.formatted(.hash)
    case .rankAndCount:
      return String(
        localized: "\(value.rank.formatted(.hash)) Count: \(value.value.formatted(.number))",
        bundle: #bundle, comment: "ranking.rankAndCount")
    }
  }
}

extension Ranking {
  package func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  package func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Ranking {
    style.format(self)
  }
}

extension FormatStyle where Self == Ranking.FormatStyle {
  package static var rankOnly: Self { .init(.rankOnly) }
  package static var rankAndCount: Self { .init(.rankAndCount) }

  package static func ranking(style: Ranking.FormatStyle.Style = .rankOnly) -> Self {
    .init(style)
  }
}
