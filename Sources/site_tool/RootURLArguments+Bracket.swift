//
//  RootURLArguments+Bracket.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func bracket() async throws -> Bracket<ArchivePath, ArchivePath> {
    await Bracket(
      music: try await music().showsOnly,
      venueIdentifier: { ArchivePath.venue($0) },
      artistIdentifier: { ArchivePath.artist($0) },
      showIdentifier: { ArchivePath.show($0) },
      annumIdentifier: { ArchivePath.year($0.annum) },
      decadeIdentifier: {
        guard case .year(let year) = $0 else { return .unknown }
        return year.decade
      })
  }
}
