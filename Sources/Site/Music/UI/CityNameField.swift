//
//  CityNameField.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/30/26.
//

import SwiftUI

/// The city the location filter uses: the current city, selected when tapped, or a typed one.
struct CityNameField: View {
  @Environment(NearbyModel.self) private var nearbyModel: NearbyModel?
  @Environment(VaultModel.self) private var model: VaultModel?

  @State private var draft = ""
  #if !os(tvOS)
    @State private var selection: TextSelection?
  #endif
  @FocusState private var focused: Bool

  private var currentCity: String? {
    model?.locationAuthorization == .allowed ? model?.currentCity : nil
  }

  private var prompt: String {
    guard model?.locationAuthorization == .allowed else { return String(localized: "City Name") }
    return currentCity ?? String(localized: "Current Location")
  }

  /// The current city is not stored, so the filter keeps following the location.
  private func commit() {
    nearbyModel?.cityName = storedCityName(typed: draft, current: currentCity)
  }

  private func showCity() {
    draft = nearbyModel?.effectiveCity(current: currentCity) ?? ""
  }

  #if !os(tvOS)
    private func selectAll() {
      guard !draft.isEmpty else { return }
      selection = TextSelection(range: draft.startIndex..<draft.endIndex)
    }
  #endif

  @ViewBuilder private var field: some View {
    #if os(tvOS)
      TextField(String(localized: "City"), text: $draft, prompt: Text(prompt))
    #else
      TextField(
        String(localized: "City"), text: $draft, selection: $selection, prompt: Text(prompt),
        axis: .vertical
      )
      .lineLimit(1)
    #endif
  }

  var body: some View {
    HStack {
      field
        .autocorrectionDisabled()
        #if os(iOS)
          .textInputAutocapitalization(.words)
          .submitLabel(.done)
        #endif
        .focused($focused)
        .onSubmit {
          commit()
          focused = false
        }
      if !draft.isEmpty {
        Button {
          draft = ""
          focused = true
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "Clear City"))
      }
    }
    #if os(iOS)
      // Room above and below the text, so the selection handles are not clipped.
      .padding(.vertical, 12)
    #endif
    .onAppear { showCity() }
    .onChange(of: currentCity) {
      if !focused, nearbyModel?.cityName.isEmpty ?? true { showCity() }
    }
    .onChange(of: draft) { old, new in
      // A vertical-axis field turns Return into a newline; that is the submit.
      if new.contains("\n") {
        let stripped = new.replacingOccurrences(of: "\n", with: "")
        draft = stripped.isEmpty ? old : stripped
        focused = false
      }
      commit()
    }
    #if !os(tvOS)
      .task(id: focused) {
        guard focused else { return }
        await Task.yield()
        selectAll()
      }
    #endif
  }
}
