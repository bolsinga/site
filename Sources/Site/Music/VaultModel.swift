//
//  VaultModel.swift
//
//
//  Created by Greg Bolsinga on 7/12/23.
//

import Combine
import CoreLocation
import Foundation
import os

extension Logger {
  static let vaultModel = Logger(category: "vaultModel")
}

enum VaultError: Error {
  case illegalURL(String)
}

extension VaultError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .illegalURL(let urlString):
      return "URL (\(urlString)) is not valid."
    }
  }
}

@MainActor public final class VaultModel: ObservableObject {
  let urlString: String

  @Published public var vault: Vault?
  @Published var error: Error?
  @Published var todayConcerts: [Concert] = []
  @Published var venuePlacemarks: [Venue.ID: CLPlacemark] = [:]

  public init(urlString: String, vault: Vault? = nil, error: Error? = nil) {
    self.urlString = urlString
    self.vault = vault
    self.error = error
  }

  public func load() async {
    Logger.vaultModel.log("start")
    defer {
      Logger.vaultModel.log("end")
    }
    do {
      guard let url = URL(string: urlString) else { throw VaultError.illegalURL(urlString) }

      error = nil
      vault = try await Vault.load(url: url)
      updateTodayConcerts()
      Task {
        await monitorDayChanges()
      }
      Task {
        await geocodeVenues()
      }
    } catch {
      Logger.vaultModel.log("error: \(error.localizedDescription, privacy: .public)")
      self.error = error
    }
  }

  private func updateTodayConcerts() {
    guard let vault else {
      Logger.vaultModel.log("No Vault to calculate todayConcerts.")
      return
    }

    todayConcerts = vault.concerts(on: Date.now)

    Logger.vaultModel.log("Today Count: \(self.todayConcerts.count, privacy: .public)")
  }

  private func monitorDayChanges() async {
    Logger.vaultModel.log("start day monitoring")
    defer {
      Logger.vaultModel.log("end day monitoring")
    }
    for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
      Logger.vaultModel.log("day changed")
      updateTodayConcerts()
    }
  }

  private func geocodeVenues() async {
    guard let vault else {
      Logger.vaultModel.log("No Vault to geocode venues.")
      return
    }

    Logger.vaultModel.log("start batch geocode")
    defer {
      Logger.vaultModel.log("end batch geocode")
    }

    do {
      for try await (digest, placemark) in BatchGeocode(
        atlas: vault.atlas, geocodables: vault.venueDigests)
      {
        Logger.vaultModel.log("geocoded: \(digest.id, privacy: .public)")
        venuePlacemarks[digest.id] = placemark
      }
    } catch {
      Logger.vaultModel.log("batch geocode error: \(error, privacy: .public)")
    }
  }
}
