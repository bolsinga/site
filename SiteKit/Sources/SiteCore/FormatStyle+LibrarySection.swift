//
//  FormatStyle+LibrarySection.swift
//
//
//  Created by Greg Bolsinga on 4/8/23.
//

import Foundation

extension LibrarySection {
  package struct FormatStyle: Codable, Equatable, Hashable {
    package enum Style: Codable, Equatable, Hashable {
      case short
      case long
    }

    package let style: Style

    package init(_ style: Style = .long) {
      self.style = style
    }

    package func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension LibrarySection.FormatStyle: Foundation.FormatStyle {
  package func format(_ value: LibrarySection) -> String {
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
  package func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  package func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == LibrarySection {
    style.format(self)
  }
}

extension FormatStyle where Self == LibrarySection.FormatStyle {
  package static var short: Self { .init(.short) }
  package static var long: Self { .init(.long) }

  package static func librarySection(style: LibrarySection.FormatStyle.Style = .long) -> Self {
    .init(style)
  }
}
