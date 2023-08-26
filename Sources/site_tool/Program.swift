//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation
import Site

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

  @Option(
    name: .customLong("json"),
    help: "Pass this to output json files to a directory.",
    transform: ({
      let url = URL(filePath: $0, directoryHint: .isDirectory)
      let manager = FileManager.default
      if !manager.fileExists(atPath: url.relativePath) {
        try manager.createDirectory(at: url, withIntermediateDirectories: true)
      }
      return url
    })
  )
  var jsonDirectoryURL: URL? = nil

  func run() async throws {
    let diary = try await Diary.load(url: rootURL.appending(path: "diary.json"))
    print("\(diary.title) has \(diary.entries.count) entries.")

    try jsonDirectoryURL?.appending(path: "diary.json").writeJSON(diary)

    let vault = try await Vault.load(url: rootURL.appending(path: "music.json"))
    let music = vault.music

    print("Albums: \(music.albums.count)")
    print("Artists: \(music.artists.count)")
    print("Relations: \(music.relations.count)")
    print("Shows: \(music.shows.count)")
    print("Songs: \(music.songs.count)")
    print("Venues: \(music.venues.count)")

    let sortedShows = music.shows.sorted {
      vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }
    for show in sortedShows.reversed() {
      let concert = vault.concert(from: show)
      print(concert.formatted(.full, lookup: vault.lookup))
    }

    let sortedAlbums = music.albums.sorted {
      vault.comparator.albumCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
    }
    for album in sortedAlbums {
      print(vault.description(for: album))
    }

    let albumMap: [Album.ID: Album] = music.albums.reduce(into: [:]) { $0[$1.id] = $1 }
    for artist in music.artists.sorted(by: vault.comparator.libraryCompare(lhs:rhs:)) {
      print(vault.description(for: artist, albumMap: albumMap))
    }

    for venue in music.venues.sorted(by: vault.comparator.libraryCompare(lhs:rhs:)) {
      print(vault.description(for: venue))
    }

    for location in music.venues.map({ $0.location }).sorted(by: <) {
      print(vault.description(for: location))
    }

    for artist in music.artists.sorted(by: vault.comparator.libraryCompare(lhs:rhs:)) {
      let shows = vault.music.showsForArtist(artist).sorted {
        vault.comparator.showCompare(lhs: $0, rhs: $1, lookup: vault.lookup)
      }
      if !shows.isEmpty {
        print(vault.description(for: artist, shows: shows))
      }
    }

    try jsonDirectoryURL?.appending(path: "music.json").writeJSON(music)
  }
}
