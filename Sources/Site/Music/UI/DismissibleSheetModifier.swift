//
//  DismissibleSheetModifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/19/25.
//

import SwiftUI

struct DismissibleSheetModifier<SheetContent>: ViewModifier where SheetContent: View {
  @Binding var showSheet: Bool
  @ViewBuilder let sheetContent: () -> SheetContent

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $showSheet) {
        VStack {
          sheetContent()
          #if os(macOS)
            // FIXME : 26 add role: .close
            Button("Done") { showSheet = false }
          #endif
        }
        .padding(10)
        .presentationDetents([.medium, .large])
      }
  }
}

extension View {
  func dismissibleSheet<SheetContent: View>(
    isPresented: Binding<Bool>, sheetContent: @escaping () -> SheetContent
  ) -> some View {
    modifier(DismissibleSheetModifier(showSheet: isPresented, sheetContent: sheetContent))
  }
}
