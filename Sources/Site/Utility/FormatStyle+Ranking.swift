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
      return String(
        localized: "Rank: \(value.rank)", bundle: .module, comment: "Ranking.FormatStyle.rankOnly")
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

  static func librarySection(style: Ranking.FormatStyle.Style = .rankOnly) -> Self {
    .init(style)
  }
}
