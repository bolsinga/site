//
//  ArchivePath+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation

extension ArchivePath {
  public static let showPrefix = "sh"
  public static let venuePrefix = "v"
  public static let artistPrefix = "ar"
  static let yearPrefix = "y"
  static let separator = "-"

  var prefix: String {
    {
      switch self {
      case .show(_):
        return ArchivePath.showPrefix
      case .venue(_):
        return ArchivePath.venuePrefix
      case .artist(_):
        return ArchivePath.artistPrefix
      case .year(_):
        return ArchivePath.yearPrefix
      }
    }() + ArchivePath.separator
  }

  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case json
      case urlPath
    }

    let style: Style

    public init(_ style: Style = .json) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension ArchivePath.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: ArchivePath) -> String {
    switch style {
    case .json:
      return value.prefix
        + {
          switch value {
          case .show(let iD):
            return iD
          case .venue(let iD):
            return iD
          case .artist(let iD):
            return iD
          case .year(let annum):
            return annum.formatted(.json)
          }
        }()
    case .urlPath:
      switch value {
      case .show(let iD):
        return "/dates/\(iD).html"
      case .venue(let iD):
        return "/venues/\(iD).html"
      case .artist(let iD):
        return "/bands/\(iD).html"
      case .year(let annum):
        return "/dates/\(annum.formatted(.urlPath)).html"
      }
    }
  }
}

extension ArchivePath {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == ArchivePath {
    style.format(self)
  }
}

extension FormatStyle where Self == ArchivePath.FormatStyle {
  public static var json: Self { .init(.json) }
  public static var urlPath: Self { .init(.urlPath) }

  static func archivePath(style: ArchivePath.FormatStyle.Style = .json) -> Self {
    .init(style)
  }
}
