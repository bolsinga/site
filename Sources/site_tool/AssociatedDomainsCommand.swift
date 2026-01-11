//
//  AssociatedDomainsCommand.swift
//  site
//
//  Created by Greg Bolsinga on 6/11/23.
//

import ArgumentParser
import Foundation

struct AssociatedDomainsCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "associatedDomains",
    abstract: "Output the associated domains file for site."
  )

  @Argument(help: "Application Identifier (from developer.apple.com)")
  var applicationIdentifier: String

  @Argument(help: "Bundle Identifier")
  var bundleIdentifier: String

  func run() async throws {

    let contents = """
      {
        "applinks" : {
          "details" : [
            {
              "appIDs" : [ "\(applicationIdentifier).\(bundleIdentifier)" ],
              "components" : [
                 {
                    "/": "/bands/*",
                    "comment": "Allows artists."
                 },
                 {
                    "/": "/dates/*",
                    "comment": "Allows shows and today."
                 },
                 {
                    "/": "/venues/*",
                    "comment": "Allows venues."
                 },
                 {
                    "/": "/stats.html",
                    "comment": "Allows Stats."
                 },
                 {
                    "/": "/settings.html",
                    "comment": "Allows Settings."
                 },
                 {
                    "/": "/search.html",
                    "comment": "Allows Search."
                 }
              ]
            }
          ]
        }
      }
      """
    print(contents)
  }
}
