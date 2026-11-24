//
//  Gate.swift
//  site
//
//  Created by Greg Bolsinga on 11/22/26.
//

/// Holds a task until the test opens it, so a test can order concurrent work without sleeping.
actor Gate {
  private var isOpen = false
  private var waiters = [CheckedContinuation<Void, Never>]()

  func wait() async {
    if isOpen { return }
    await withCheckedContinuation { waiters.append($0) }
  }

  func open() {
    isOpen = true
    for waiter in waiters { waiter.resume() }
    waiters = []
  }
}
