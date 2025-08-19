//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  let decadesMap: [Decade: [Annum: [Concert.ID]]]

  var body: some View {
    List {
      ForEach(decadesMap.keys.sorted(), id: \.self) { decade in
        let decadeMap = decadesMap[decade] ?? [:]
        Section {
          ForEach(decadeMap.keys.sorted(), id: \.self) { annum in
            let concerts = decadeMap[annum] ?? []
            NavigationLink(value: annum) {
              LabeledContent(
                annum.formatted(),
                value: String(localized: "\(concerts.count) Show(s)", bundle: .module))
            }
          }
        } header: {
          Text(decade.formatted(.defaultDigits))
        }
      }
    }
    .listStyle(.plain)
    .navigationTitle(Text("Show Years", bundle: .module))
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  ShowYearList(decadesMap: model.vault.decadesMap)
}
