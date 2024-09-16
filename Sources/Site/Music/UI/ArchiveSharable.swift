//
//  ArchiveSharable.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

// iOS Only:
// When sharing via Messages, link is shared followed by the message text.
// When sharing via Mail, subject is as expected, and message is link followed by message text.
// macos ventura: no subject nor message shown messages nor mail

protocol ArchiveSharable {
  var subject: Text { get }
  var message: Text { get }
}

extension Concert: ArchiveSharable {
  var subject: Text {
    Text(self.formatted(.headlinerAndVenue))
  }

  var message: Text {
    Text(self.formatted(.full))
  }
}

extension Venue: ArchiveSharable {
  private var descriptor: String {
    String(localized: "Shows at \(self.name)", bundle: .module)
  }

  var subject: Text {
    Text(descriptor)
  }

  var message: Text {
    Text(descriptor)
  }
}

extension Annum: ArchiveSharable {
  var subject: Text {
    Text(self.formatted(.shared))
  }

  var message: Text {
    Text(self.formatted(.shared))
  }
}

extension Artist: ArchiveSharable {
  private var descriptor: String {
    String(localized: "Shows with \(self.name)", bundle: .module)
  }

  var subject: Text {
    Text(descriptor)
  }

  var message: Text {
    Text(descriptor)
  }
}
