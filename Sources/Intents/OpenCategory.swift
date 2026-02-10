//
//  OpenCategory.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/7/25.
//

import AppIntents
import Foundation
import os

extension Logger {
  fileprivate static let openCategory = Logger(category: "openCategory")
}

private enum OpenCategoryError: Error, CustomLocalizedStringResourceConvertible {
  case noURL

  var localizedStringResource: LocalizedStringResource {
    switch self {
    case .noURL:
      "The category does not have a URL."
    }
  }
}

struct OpenCategory: AppIntent {
  static let title = LocalizedStringResource("Open Category")

  static let description = IntentDescription("Displays Category Details in App.")

  static let openAppWhenRun: Bool = true

  static var parameterSummary: some ParameterSummary {
    Summary("Open \(\.$target)")
  }

  @Parameter(title: "Category")
  var target: CategoryEnum

  @MainActor func perform() async throws -> some IntentResult & OpensIntent {
    guard let categoryURL = vault.url(for: target.archiveCategory) else {
      throw OpenCategoryError.noURL
    }
    Logger.openCategory.log("Intent Open URL: \(categoryURL.absoluteString)")
    return .result(opensIntent: OpenURLIntent(categoryURL))
  }

  @Dependency
  private var vault: Vault<BasicIdentifier>
}
