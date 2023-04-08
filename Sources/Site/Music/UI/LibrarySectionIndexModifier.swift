//
//  LibrarySectionIndexModifier.swift
//
//
//  Created by Greg Bolsinga on 4/7/23.
//

import SwiftUI

struct LibrarySectionIndexModifier: ViewModifier {
  let sections: [LibrarySection]
  func body(content: Content) -> some View {
    ScrollViewReader { scrollProxy in
      ZStack {
        content
        VStack(alignment: .center) {
          ForEach(sections, id: \.self) { section in
            HStack {
              Spacer()
              Button(
                action: {
                  withAnimation {
                    scrollProxy.scrollTo(section)
                  }
                },
                label: {
                  Text(String(describing: section)).font(.system(size: 12))
                })
            }
          }
        }
      }
    }
  }
}

extension View {
  func sectionIndex(_ sections: [LibrarySection]) -> some View {
    modifier(LibrarySectionIndexModifier(sections: sections))
  }
}
