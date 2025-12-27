//
//  ArchivePathLink.swift
//
//
//  Created by Greg Bolsinga on 8/22/24.
//

import SwiftUI

struct ArchivePathLink<Label>: View where Label: View {
  private let archivePath: ArchivePath
  private let isPathNavigable: (ArchivePath) -> Bool
  @ViewBuilder private let labelBuilder: (() -> Label)?
  private let title: (any StringProtocol)?

  private init(
    archivePath: ArchivePath, isPathNavigable: @escaping (ArchivePath) -> Bool,
    labelBuilder: (() -> Label)?, title: (any StringProtocol)?
  ) {
    self.archivePath = archivePath
    self.isPathNavigable = isPathNavigable
    self.labelBuilder = labelBuilder
    self.title = title
  }

  init(
    archivePath: ArchivePath, isPathNavigable: @escaping (ArchivePath) -> Bool,
    labelBuilder: @escaping (() -> Label)
  ) {
    self.init(
      archivePath: archivePath, isPathNavigable: isPathNavigable, labelBuilder: labelBuilder,
      title: nil)
  }

  init(
    archivePath: ArchivePath, isPathNavigable: @escaping (ArchivePath) -> Bool,
    title: any StringProtocol
  ) where Label == Never {
    self.init(
      archivePath: archivePath, isPathNavigable: isPathNavigable, labelBuilder: nil,
      title: title)
  }

  @ViewBuilder private var labelView: some View {
    if let labelBuilder {
      labelBuilder()
    } else if let title {
      Text(title)
    }
  }

  var body: some View {
    if isPathNavigable(archivePath) {
      if let title {
        NavigationLink(title, archivePath: archivePath)
      } else {
        NavigationLink(archivePath: archivePath) { labelView }
      }
    } else {
      labelView
    }
  }
}
