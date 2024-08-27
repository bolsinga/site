//
//  ArchiveCategory+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import Foundation

extension ArchiveCategory {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case urlPath
    }

    let style: Style

    public init(_ style: Style = .urlPath) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension ArchiveCategory.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: ArchiveCategory) -> String {
    switch style {
    case .urlPath:
      switch value {
      case .today:
        return "/dates/today.html"
      case .stats:
        return "/stats.html"
      case .shows:
        return "/dates/stats.html"
      case .venues:
        return "/venues/stats.html"
      case .artists:
        return "/bands/stats.html"
      }
    }
  }
}

extension ArchiveCategory {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == ArchiveCategory {
    style.format(self)
  }
}

extension FormatStyle where Self == ArchiveCategory.FormatStyle {
  public static var urlPath: Self { .init(.urlPath) }

  static func archiveCategory(style: ArchiveCategory.FormatStyle.Style = .urlPath) -> Self {
    .init(style)
  }
}
