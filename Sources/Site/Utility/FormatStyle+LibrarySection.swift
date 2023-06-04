//
//  FormatStyle+LibrarySection.swift
//
//
//  Created by Greg Bolsinga on 4/8/23.
//

import Foundation

extension LibrarySection {
  struct FormatStyle: Codable, Equatable, Hashable {
    enum Style: Codable, Equatable, Hashable {
      case short
      case long
    }

    let style: Style

    public init(_ style: Style = .long) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension LibrarySection.FormatStyle: Foundation.FormatStyle {
  func format(_ value: LibrarySection) -> String {
    switch value {
    case .alphabetic(let string):
      return string
    case .numeric:
      if case .short = style {
        return "#"
      }
      return String(
        localized: "Numeric", bundle: .module,
        comment: "String used to describe LibrarySection.numeric.")
    case .punctuation:
      if case .short = style {
        return "!"
      }
      return String(
        localized: "Punctuation", bundle: .module,
        comment: "String used to describe LibrarySection.punctuation.")
    }
  }
}

extension LibrarySection {
  func formatted() -> String {
    Self.FormatStyle().format(self)
  }

  func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == LibrarySection {
    style.format(self)
  }
}

extension FormatStyle where Self == LibrarySection.FormatStyle {
  static var short: Self { .init(.short) }
  static var long: Self { .init(.long) }

  static func librarySection(style: LibrarySection.FormatStyle.Style = .long) -> Self {
    .init(style)
  }
}
