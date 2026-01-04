//
//  ArchiveSharable.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import Foundation

// iOS Only:
// When sharing via Messages, link is shared followed by the message text.
// When sharing via Mail, subject is as expected, and message is link followed by message text.
// macos ventura: no subject nor message shown messages nor mail

protocol ArchiveSharable {
  var subject: String { get }
  var message: String { get }
}

extension Concert: ArchiveSharable {
  var subject: String { self.formatted(.headlinerAndVenue) }
  var message: String { self.formatted(.full) }
}

extension Venue: ArchiveSharable {
  var subject: String { String(localized: "Shows at \(self.name)") }
  var message: String { subject }
}

extension VenueDigest: ArchiveSharable {
  var subject: String { venue.subject }
  var message: String { venue.message }
}

extension Annum: ArchiveSharable {
  var subject: String { formatted(.shared) }
  var message: String { subject }
}

extension AnnumDigest: ArchiveSharable {
  var subject: String { annum.subject }
  var message: String { annum.message }
}

extension Artist: ArchiveSharable {
  var subject: String { String(localized: "Shows with \(self.name)") }
  var message: String { subject }
}

extension ArtistDigest: ArchiveSharable {
  var subject: String { artist.subject }
  var message: String { artist.message }
}
