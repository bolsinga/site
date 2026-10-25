//
//  CancellableWaiterTests.swift
//
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Synchronization
import Testing

@testable import SiteApp

struct CancellableWaiterTests {
  @Test func deliveredWhileWaitingIsReturned() async {
    let waiter = CancellableWaiter<Int>()
    let task = Task { await waiter.wait() }
    await Task.yield()
    waiter.deliver(7)
    #expect(await task.value == 7)
  }

  @Test func deliveredBeforeWaitingIsReturned() async {
    let waiter = CancellableWaiter<Int>()
    waiter.deliver(3)
    #expect(await waiter.wait() == 3)
  }

  @Test func onlyTheFirstDeliveryCounts() async {
    let waiter = CancellableWaiter<Int>()
    waiter.deliver(1)
    waiter.deliver(2)
    #expect(await waiter.wait() == 1)
  }

  @Test func cancelWhileWaitingReturnsNil() async {
    let waiter = CancellableWaiter<Int>()
    let task = Task { await waiter.wait() }
    await Task.yield()
    task.cancel()
    #expect(await task.value == nil)
  }

  @Test func cancelBeforeWaitingReturnsNil() async {
    let waiter = CancellableWaiter<Int>()
    let gate = Mutex(false)
    let task = Task {
      while !gate.withLock({ $0 }) { await Task.yield() }
      return await waiter.wait()
    }
    task.cancel()
    gate.withLock { $0 = true }
    #expect(await task.value == nil)
  }

  @Test func deliveryAfterCancelIsIgnored() async {
    let waiter = CancellableWaiter<Int>()
    let task = Task {
      await waiter.wait()
    }
    task.cancel()
    #expect(await task.value == nil)
    waiter.deliver(9)
  }
}
