//
//  Annum+ParseableFormatStyle.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation
import MusicData

extension Annum.FormatStyle {
  public struct ParseStrategy: Foundation.ParseStrategy {
    enum ValidationError: Error {
      case invalidCharacters
      case emptyInput
      case unknown
    }

    static let validCharacterSet = CharacterSet(charactersIn: "0123456789")

    public init() {}

    public func parse(_ value: String) throws -> Annum {
      let trimmedValue = value.trimmingCharacters(in: .whitespaces)

      guard !trimmedValue.isEmpty else { throw ValidationError.emptyInput }

      if trimmedValue == Annum.FormatStyle.unknown {
        return .unknown
      }

      guard trimmedValue.rangeOfCharacter(from: Self.validCharacterSet.inverted) == nil else {
        throw ValidationError.invalidCharacters
      }

      if let validAnnum = Int(trimmedValue) {
        return .year(validAnnum)
      }

      throw ValidationError.unknown
    }
  }
}

extension Annum.FormatStyle: ParseableFormatStyle {
  public var parseStrategy: Annum.FormatStyle.ParseStrategy {
    .init()
  }
}

extension Annum {
  init(_ string: String) throws {
    self = try Annum.FormatStyle().parseStrategy.parse(string)
  }

  init<T, Value>(_ value: Value, standard: T) throws
  where T: ParseStrategy, Value: StringProtocol, T.ParseInput == String, T.ParseOutput == Annum {
    self = try standard.parse(value.description)
  }
}

extension ParseableFormatStyle where Self == Annum.FormatStyle {
  public static var annum: Self { .init() }
}
