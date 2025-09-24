//
//  TitledSheetModifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/19/25.
//

import SwiftUI

struct TitledSheetModifier<SheetContent: View>: ViewModifier {
  @Binding var showSheet: Bool
  let title: LocalizedStringResource
  @ViewBuilder let sheetContent: SheetContent

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $showSheet) {
        VStack {
          HStack {
            Text(title).font(.title).fontWeight(.bold)
            #if os(macOS)
              Spacer()
              // FIXME : 26 add role: .close
              Button("Done") { showSheet = false }
            #endif
          }
          sheetContent
        }
        .padding(10)
        .presentationDetents([.medium, .large])
      }
  }
}

extension View {
  func titledSheet<SheetContent: View>(
    isPresented: Binding<Bool>, title: LocalizedStringResource, sheetContent: () -> SheetContent
  ) -> some View {
    modifier(TitledSheetModifier(showSheet: isPresented, title: title, sheetContent: sheetContent))
  }
}
