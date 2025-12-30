//
//  ConcertBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/18/23.
//

import SwiftUI

struct ConcertBlurb: View {
  enum DateFormat {
    case noYear
    case relative
  }

  let venue: String?
  let date: PartialDate
  let performers: [String]
  let dateFormat: DateFormat

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      if let venue {
        Text(venue).font(.headline)
      }
      switch dateFormat {
      case .noYear:
        Text(date.formatted(.noYear))
          .font(.footnote)
      case .relative:
        if let date = date.date {
          Text(date.formatted(.relative(presentation: .numeric)))
            .font(.footnote)
        }
      }
    }
  }

  var body: some View {
    HStack {
      PerformersView(performers: performers)
      Spacer()
      detailsView
    }
  }
}

extension ConcertBlurb {
  fileprivate init(concert: Concert, dateFormat: DateFormat) {
    self.init(
      venue: concert.venue?.name, date: concert.show.date, performers: concert.performers,
      dateFormat: dateFormat)
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ConcertBlurb(concert: model.vault.concertMap["sh1"]!, dateFormat: .noYear)
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ConcertBlurb(concert: model.vault.concertMap["sh500"]!, dateFormat: .relative)
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ConcertBlurb(concert: model.vault.concertMap["sh100"]!, dateFormat: .noYear)
}
