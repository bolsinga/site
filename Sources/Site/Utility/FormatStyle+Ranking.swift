//
//  FormatStyle+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Ranking {
  struct FormatStyle: Codable, Equatable, Hashable {
    enum Style: Codable, Equatable, Hashable {
      case rankOnly
      case rankAndCount
    }

    let style: Style

    public init(_ style: Style = .rankOnly) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension Ranking.FormatStyle: Foundation.FormatStyle {
  func format(_ value: Ranking) -> String {
    switch style {
    case .rankOnly:
      return value.rank.formatted(.hash)
    case .rankAndCount:
      return String(
        localized: "\(value.rank.formatted(.hash)) Count: \(value.value.formatted(.number))",
        bundle: .module, comment: "ranking.rankAndCount")
    }
  }
}

extension Ranking {
  func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Ranking {
    style.format(self)
  }
}

extension FormatStyle where Self == Ranking.FormatStyle {
  static var rankOnly: Self { .init(.rankOnly) }
  static var rankAndCount: Self { .init(.rankAndCount) }

  static func ranking(style: Ranking.FormatStyle.Style = .rankOnly) -> Self {
    .init(style)
  }
}
