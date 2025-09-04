//
//  PathRestorableLink.swift
//
//
//  Created by Greg Bolsinga on 8/22/24.
//

import MusicData
import SwiftUI

struct PathRestorableLink<Label>: View where Label: View {
  private let pathRestorable: PathRestorable
  private let isPathNavigable: (PathRestorable) -> Bool
  @ViewBuilder private let labelBuilder: (() -> Label)?
  private let title: (any StringProtocol)?

  private init(
    pathRestorable: any PathRestorable, isPathNavigable: @escaping (any PathRestorable) -> Bool,
    labelBuilder: (() -> Label)?, title: (any StringProtocol)?
  ) {
    self.pathRestorable = pathRestorable
    self.isPathNavigable = isPathNavigable
    self.labelBuilder = labelBuilder
    self.title = title
  }

  init(
    pathRestorable: any PathRestorable, isPathNavigable: @escaping (any PathRestorable) -> Bool,
    labelBuilder: @escaping (() -> Label)
  ) {
    self.init(
      pathRestorable: pathRestorable, isPathNavigable: isPathNavigable, labelBuilder: labelBuilder,
      title: nil)
  }

  init(
    pathRestorable: any PathRestorable, isPathNavigable: @escaping (any PathRestorable) -> Bool,
    title: any StringProtocol
  ) where Label == Never {
    self.init(
      pathRestorable: pathRestorable, isPathNavigable: isPathNavigable, labelBuilder: nil,
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
    if isPathNavigable(pathRestorable) {
      if let title {
        NavigationLink(title, value: pathRestorable)
      } else {
        NavigationLink(value: pathRestorable) { labelView }
      }
    } else {
      labelView
    }
  }
}
