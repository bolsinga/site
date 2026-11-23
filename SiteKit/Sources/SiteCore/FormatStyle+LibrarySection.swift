//
//  FormatStyle+LibrarySection.swift
//
//
//  Created by Greg Bolsinga on 4/8/23.
//

import Foundation
import Shared

extension LibrarySection {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case short
      case long
    }

    public let style: Style

    public init(_ style: Style = .long) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension LibrarySection.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: LibrarySection) -> String {
    switch value {
    case .alphabetic(let string):
      return string
    case .numeric:
      if case .short = style {
        return "#"
      }
      return String(localized: "Numeric", bundle: #bundle)
    case .punctuation:
      if case .short = style {
        return "!"
      }
      return String(localized: "Punctuation", bundle: #bundle)
    }
  }
}

extension LibrarySection {
  public func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == LibrarySection {
    style.format(self)
  }
}

extension FormatStyle where Self == LibrarySection.FormatStyle {
  public static var short: Self { .init(.short) }
  public static var long: Self { .init(.long) }

  public static func librarySection(style: LibrarySection.FormatStyle.Style = .long) -> Self {
    .init(style)
  }
}
