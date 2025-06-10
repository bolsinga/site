//
//  NSCodingCodable.swift
//
//
//  Created by Greg Bolsinga on 9/23/23.
//

import Foundation

@propertyWrapper
struct NSCodingCodable<T: NSObject & NSCoding & Sendable>: Codable {
  enum NSCodingCodableError: Error {
    case decodeFailure
  }

  let wrappedValue: T

  init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let data = try container.decode(Data.self)

    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
    unarchiver.requiresSecureCoding = Self.supportsSecureCoding

    guard let wrappedValue = T(coder: unarchiver) else {
      throw NSCodingCodableError.decodeFailure
    }

    unarchiver.finishDecoding()

    self.init(wrappedValue: wrappedValue)
  }

  func encode(to encoder: Encoder) throws {
    let archiver = NSKeyedArchiver(requiringSecureCoding: Self.supportsSecureCoding)
    wrappedValue.encode(with: archiver)
    archiver.finishEncoding()

    var container = encoder.singleValueContainer()
    try container.encode(archiver.encodedData)
  }

  private static var supportsSecureCoding: Bool {
    (T.self as? NSSecureCoding.Type)?.supportsSecureCoding ?? false
  }
}
