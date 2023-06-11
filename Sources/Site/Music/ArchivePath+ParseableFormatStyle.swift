//
//  ArchivePath+ParseableFormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation

extension ArchivePath.FormatStyle {
  public struct ParseStrategy: Foundation.ParseStrategy {
    enum ValidationError: Error {
      case emptyInput
      case invalidSeparator
      case invalidPrefixCharacters
      case invalidPrefix
    }

    static let validPrefixSet = CharacterSet(charactersIn: ArchivePath.showPrefix)
      .union(CharacterSet(charactersIn: ArchivePath.venuePrefix))
      .union(CharacterSet(charactersIn: ArchivePath.artistPrefix))
      .union(CharacterSet(charactersIn: ArchivePath.yearPrefix))

    static let validSeparatorSet = CharacterSet(charactersIn: ArchivePath.separator)

    public init() {}

    public func parse(_ value: String) throws -> ArchivePath {
      let trimmedValue = value.trimmingCharacters(in: .whitespaces)

      guard !trimmedValue.isEmpty else {
        throw ValidationError.emptyInput
      }

      let components = trimmedValue.components(
        separatedBy: ArchivePath.FormatStyle.ParseStrategy.validSeparatorSet)

      guard components.count >= 2 else {
        throw ValidationError.invalidSeparator
      }

      let prefix = components[0]

      guard prefix.rangeOfCharacter(from: Self.validPrefixSet.inverted) == nil else {
        throw ValidationError.invalidPrefixCharacters
      }

      let identifier = String(trimmedValue.dropFirst(prefix.count + ArchivePath.separator.count))

      switch prefix {
      case ArchivePath.showPrefix:
        return ArchivePath.show(identifier)
      case ArchivePath.venuePrefix:
        return ArchivePath.venue(identifier)
      case ArchivePath.artistPrefix:
        return ArchivePath.artist(identifier)
      case ArchivePath.yearPrefix:
        return ArchivePath.year(try Annum(identifier))
      default:
        throw ValidationError.invalidPrefix
      }
    }
  }
}

extension ArchivePath.FormatStyle: ParseableFormatStyle {
  public var parseStrategy: ArchivePath.FormatStyle.ParseStrategy {
    .init()
  }
}

extension ArchivePath {
  init(_ string: String) throws {
    self = try ArchivePath.FormatStyle().parseStrategy.parse(string)
  }

  init<T, Value>(_ value: Value, standard: T) throws
  where
    T: ParseStrategy, Value: StringProtocol, T.ParseInput == String, T.ParseOutput == ArchivePath
  {
    self = try standard.parse(value.description)
  }
}

extension ParseableFormatStyle where Self == ArchivePath.FormatStyle {
  public static var archivePath: Self { .init() }
}
