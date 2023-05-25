//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  @Environment(\.vault) private var vault: Vault

  let shows: [Show]

  private var yearPartialDates: [PartialDate] {
    return Array(
      Set(shows.map { $0.date.year != nil ? PartialDate(year: $0.date.year!) : PartialDate() })
    ).sorted(by: <)
  }

  var body: some View {
    List(yearPartialDates, id: \.self) { yearPartialDate in
      NavigationLink(value: yearPartialDate) {
        LabeledContent(
          yearPartialDate.formatted(.yearOnly),
          value: String(
            localized:
              "\(vault.music.showsForYear(yearPartialDate).count) Show(s)", bundle: .module,
            comment: "Value for the ShowYearList Shows per year."))
      }
    }
    .listStyle(.plain)
    .navigationTitle(Text("Show Years", bundle: .module, comment: "Title for the ShowYearList."))
    .navigationDestination(for: PartialDate.self) {
      ShowList(shows: vault.music.showsForYear($0), yearPartialDate: $0)
    }
  }
}

struct ShowYearList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ShowYearList(shows: vault.music.shows)
        .environment(\.vault, vault)
        .archiveDestinations()
    }
  }
}
