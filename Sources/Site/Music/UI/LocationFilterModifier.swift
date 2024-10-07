//
//  LocationFilterModifier.swift
//
//
//  Created by Greg Bolsinga on 10/5/23.
//

import SwiftUI

struct LocationFilterModifier: ViewModifier {
  let model: NearbyModel

  func body(content: Content) -> some View {
    @Bindable var bindableModel = model
    content
      .toolbar { LocationFilterToolbarContent(isOn: $bindableModel.locationFilter.toggle) }
  }
}

extension View {
  func locationFilter(_ model: NearbyModel) -> some View {
    modifier(LocationFilterModifier(model: model))
  }
}
