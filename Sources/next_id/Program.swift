//
//  Program.swift
//
//  Created by Greg Bolsinga on 8/3/23.
//

import ArgumentParser
import Foundation

@main
struct Program: AsyncParsableCommand {
  enum URLError: Error {
    case notURLString(String)
  }

  @Argument(
    help:
      "The root URL for the json files.",
    transform: ({
      let url = URL(string: $0)
      guard let url else { throw URLError.notURLString($0) }
      return url
    })
  )
  var rootURL: URL

  func run() async throws {
    let vault = try await Vault.load(
      url: rootURL.appending(path: "music.json"), artistsWithShowsOnly: false)

    print("Next Show: \(vault.nextShowID)")
    print("Next Venue: \(vault.nextVenueID)")
    print("Next Artist: \(vault.nextArtistID)")
  }
}
