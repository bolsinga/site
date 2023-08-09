//
//  ArchiveCategory+ParseableFormatStyle.swift
//
//
//  Created by Greg Bolsinga on 8/8/23.
//

import Foundation

extension ArchiveCategory.FormatStyle {
  public struct URLPathParseStrategy: Foundation.ParseStrategy {
    enum ValidationError: Error {
      case path
      case filenameFormat
      case fileType
      case archiveCategoryType
    }

    public init() {}

    public func parse(_ urlPath: String) throws -> ArchiveCategory {
      let pathComponents = urlPath.components(separatedBy: "/")

      let directory = (pathComponents.count == 3) ? pathComponents[1] : nil

      let filename = try {
        switch pathComponents.count {
        case 2:
          return pathComponents[1]
        case 3:
          return pathComponents[2]
        default:
          throw ValidationError.path
        }
      }()

      let filenameComponents = filename.components(separatedBy: ".")
      guard filenameComponents.count == 2 else {
        throw ValidationError.filenameFormat
      }

      let filenameExtension = filenameComponents[1]
      guard filenameExtension == "html" else {
        throw ValidationError.fileType
      }

      switch (directory, filenameComponents[0]) {
      case (nil, "stats"):
        return ArchiveCategory.stats
      case ("dates", "today"):
        return ArchiveCategory.today
      case ("dates", "stats"):
        return ArchiveCategory.shows
      case ("venues", "stats"):
        return ArchiveCategory.venues
      case ("bands", "stats"):
        return ArchiveCategory.artists
      default:
        throw ValidationError.archiveCategoryType
      }
    }
  }

  public struct URLParseStrategy: Foundation.ParseStrategy {
    enum ValidationError: Error {
      case url
      case scheme
      case path
      case fragment
      case filenameFormat
      case fileType
      case archiveCategoryType
    }

    public init() {}

    public func parse(_ url: URL) throws -> ArchiveCategory {
      let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

      guard let urlComponents else {
        throw ValidationError.url
      }

      guard let scheme = urlComponents.scheme, scheme == "https" else {
        throw ValidationError.scheme
      }

      guard urlComponents.fragment == nil else {
        throw ValidationError.fragment
      }

      return try ArchiveCategory(parse: urlComponents.path)
    }
  }
}

extension ArchiveCategory.FormatStyle: ParseableFormatStyle {
  public var parseStrategy: ArchiveCategory.FormatStyle.URLPathParseStrategy {
    .init()
  }

  public var urlParseStrategy: ArchiveCategory.FormatStyle.URLParseStrategy {
    .init()
  }
}

extension ArchiveCategory {
  init(parse string: String) throws {
    self = try ArchiveCategory.FormatStyle().parseStrategy.parse(string)
  }

  init<T, Value>(_ value: Value, standard: T) throws
  where
    T: ParseStrategy, Value: StringProtocol, T.ParseInput == String,
    T.ParseOutput == ArchiveCategory
  {
    self = try standard.parse(value.description)
  }
}

extension ArchiveCategory {
  init(_ url: URL) throws {
    self = try ArchiveCategory.FormatStyle().urlParseStrategy.parse(url)
  }

  init<T>(_ value: URL, standard: T) throws
  where
    T: ParseStrategy, T.ParseInput == URL, T.ParseOutput == ArchiveCategory
  {
    self = try standard.parse(value)
  }
}

extension ParseableFormatStyle where Self == ArchiveCategory.FormatStyle {
  public static var archiveCategory: Self { .init() }
}
