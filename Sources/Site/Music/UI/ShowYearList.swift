//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  let decadesMap: [Decade: [Annum: [Concert.ID]]]

  @State private var descending: Bool = false

  var body: some View {
    List {
      ForEach(
        decadesMap.keys.sorted { lhs, rhs in
          descending ? Decade.compareDescendingUnknownLast(lhs: lhs, rhs: rhs) : lhs < rhs
        }, id: \.self
      ) { decade in
        let decadeMap = decadesMap[decade] ?? [:]
        Section {
          ForEach(
            decadeMap.keys.sorted { lhs, rhs in
              descending ? Annum.compareDescendingUnknownLast(lhs: lhs, rhs: rhs) : lhs < rhs
            }, id: \.self
          ) { annum in
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
    .toolbar {
      ToolbarItem {
        Toggle(isOn: $descending) {
          Label {
            Text("Sort", bundle: .module)
          } icon: {
            Image(systemName: "line.3.horizontal.decrease.circle")
          }
        }
      }
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    ShowYearList(decadesMap: model.vault.decadesMap)
  }
}
