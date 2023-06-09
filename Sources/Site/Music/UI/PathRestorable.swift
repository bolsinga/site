//
//  PathRestorable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import SwiftUI

enum ArchivePath: Hashable {
  case show(Show.ID)
  case venue(Venue.ID)
  case artist(Artist.ID)
  case year(Annum)
}

protocol PathRestorable {
  var archivePath: ArchivePath { get }
}

extension Show: PathRestorable {
  var archivePath: ArchivePath { .show(id) }
}

extension Venue: PathRestorable {
  var archivePath: ArchivePath { .venue(id) }
}

extension Artist: PathRestorable {
  var archivePath: ArchivePath { .artist(id) }
}

extension Annum: PathRestorable {
  var archivePath: ArchivePath { .year(self) }
}

extension NavigationLink where Destination == Never {
  init(value: PathRestorable?, @ViewBuilder label: () -> Label) {
    self.init(value: value?.archivePath, label: label)
  }

  init<S>(_ title: S, value: PathRestorable?) where Label == Text, S: StringProtocol {
    self.init(title, value: value?.archivePath)
  }
}
