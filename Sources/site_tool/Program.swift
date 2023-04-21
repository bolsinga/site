//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation
import LoadingState
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
    var diaryLoadingState: LoadingState<Diary> = .idle
    await diaryLoadingState.load(url: rootURL.appending(path: "diary.json"))
    if let diary = diaryLoadingState.value {
      print("\(diary.title) has \(diary.entries.count) entries.")

      try jsonDirectoryURL?.appending(path: "diary.json").writeJSON(diary)
    }

    var musicLoadingState: LoadingState<Music> = .idle
    await musicLoadingState.load(url: rootURL.appending(path: "music.json"))
    if let music = musicLoadingState.value {
      let vault = Vault(music: music)
      print("Albums: \(music.albums.count)")
      print("Artists: \(music.artists.count)")
      print("Relations: \(music.relations.count)")
      print("Shows: \(music.shows.count)")
      print("Songs: \(music.songs.count)")
      print("Venues: \(music.venues.count)")

      for show in music.shows.sorted(by: vault.lookup.showCompare(lhs:rhs:)).reversed() {
        print(vault.description(for: show))
      }

      for album in music.albums.sorted(by: vault.lookup.albumCompare(lhs:rhs:)) {
        print(vault.description(for: album))
      }

      let albumMap: [Album.ID: Album] = music.albums.reduce(into: [:]) { $0[$1.id] = $1 }
      for artist in music.artists.sorted(by: libraryCompare(lhs:rhs:)) {
        print(vault.description(for: artist, albumMap: albumMap))
      }

      for venue in music.venues.sorted(by: libraryCompare(lhs:rhs:)) {
        print(vault.description(for: venue))
      }

      for location in music.venues.map({ $0.location }).sorted(by: <) {
        print(vault.description(for: location))
      }

      for artist in music.artists.sorted(by: libraryCompare(lhs:rhs:)) {
        let shows = vault.lookup.showsForArtist(artist).sorted(by: vault.lookup.showCompare(lhs:rhs:))
        if !shows.isEmpty {
          print(vault.description(for: artist, shows: shows))
        }
      }

      try jsonDirectoryURL?.appending(path: "music.json").writeJSON(music)
    }
  }
}
