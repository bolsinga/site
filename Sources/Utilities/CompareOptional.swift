//
//  CompareOptional.swift
//
//
//  Created by Greg Bolsinga on 6/26/23.
//

import Foundation

public func compareOptional<T: Comparable>(lhs: T?, rhs: T?, equalAction: (() -> Bool)? = nil)
  -> Bool
{
  if let lhs, let rhs {
    if let equalAction, lhs == rhs {
      return equalAction()
    }
    return lhs < rhs
  }

  if lhs != nil || rhs != nil {
    // Now lhs or rhs is nil. If lhs is nil it sorts before the non nil rhs
    return lhs == nil
  }

  return false
}
