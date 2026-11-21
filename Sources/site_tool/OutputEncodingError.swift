//
//  OutputEncodingError.swift
//  site_tool
//
//  Created by Greg Bolsinga on 11/21/26.
//

import Foundation

/// Thrown when a dump's JSON can't be made into text, so the command exits non-zero.
struct OutputEncodingError: LocalizedError {
  let subject: String

  var errorDescription: String? { "cannot encode \(subject)" }
}
