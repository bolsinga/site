//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Diary
import Foundation
import LoadingState
import Music

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
      print("Albums: \(music.albums.count)")
      print("Artists: \(music.artists.count)")
      print("Relations: \(music.relations.count)")
      print("Shows: \(music.shows.count)")
      print("Songs: \(music.songs.count)")
      print("Venues: \(music.venues.count)")

      for show in music.shows.sorted(by: <).reversed() {
        print(music.description(for: show))
      }

      for album in music.albums.sorted(by: <).reversed() {
        print(music.description(for: album))
      }

      for artist in music.artists.sorted(by: <) {
        print(music.description(for: artist))
      }

      for location in music.venues.map({ $0.location }).sorted(by: <) {
        print(music.description(for: location))
      }

      try jsonDirectoryURL?.appending(path: "music.json").writeJSON(music)
    }
  }
}
