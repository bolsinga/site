//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  @Environment(\.vault) private var vault: Vault

  var body: some View {
    let decadesMap = vault.lookup.decadesMap
    List {
      ForEach(decadesMap.keys.sorted(), id: \.self) { decade in
        let decadeMap = decadesMap[decade] ?? [:]
        Section {
          ForEach(decadeMap.keys.sorted(), id: \.self) { annum in
            let shows = decadeMap[annum] ?? []
            NavigationLink(value: annum) {
              LabeledContent(
                annum.formatted(),
                value: String(
                  localized: "\(shows.count) Show(s)", bundle: .module,
                  comment: "Value for the ShowYearList Shows per year."))
            }
          }
        } header: {
          Text(decade.formatted(.defaultDigits))
        }
      }
    }
    .listStyle(.plain)
    .navigationTitle(Text("Show Years", bundle: .module, comment: "Title for the ShowYearList."))
  }
}

struct ShowYearList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ShowYearList()
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
