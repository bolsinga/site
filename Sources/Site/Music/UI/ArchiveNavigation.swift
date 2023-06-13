//
//  ArchiveNavigation.swift
//
//
//  Created by Greg Bolsinga on 6/13/23.
//

import Combine

final class ArchiveNavigation: ObservableObject {
  @Published var selectedCategory: ArchiveCategory?
  @Published var navigationPath: [ArchivePath] = []
}
