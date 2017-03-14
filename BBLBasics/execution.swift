//
//  execution.swift
//  contexter
//
//  Created by Andy Park on 08/06/16.
//  Copyright © 2016 Big Bear Labs. All rights reserved.
//

import Foundation


// TODO fix this global namespace pollution appropriately.

public func periodically(every interval: TimeInterval, queue: DispatchQueue? = nil, operation: @escaping () -> Void) -> DispatchSourceTimer {

  let queue = queue ?? DispatchQueue.global(qos: .default)
  
  // initial execution.
  queue.async {
    operation()
  }
  
  // set up the timer.
  let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)

  let start = DispatchTime.now() + Double(0) / Double(NSEC_PER_SEC)
  timer.scheduleRepeating(deadline: start, interval: DispatchTimeInterval.seconds(Int(interval)), leeway: DispatchTimeInterval.seconds(0))
  timer.setEventHandler(handler: {
    operation()
  })
  timer.resume()
  
  return timer
}


public func execOnMain(_ operation: () -> Void) {
  
  if Thread.isMainThread {
    operation()
  }
  else {
    DispatchQueue.main.sync(execute: operation)
  }
}

public func execOnMainAsync(_ operation: @escaping () -> Void) {
  DispatchQueue.main.async(execute: operation)
}


public func exec(delay: TimeInterval, operation: @escaping () -> Void) {
  let queue = DispatchQueue.global(qos: .default)
  queue.asyncAfter(deadline: .now() + delay) {
    operation()
  }
}


open class LastOnlyQueue {
  
  let queue: DispatchQueue
  let interval: TimeInterval
  
  var opOnStandby: (()->())?
  
  public init(queue: DispatchQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).LastOnlyQueue"), threshold: TimeInterval = 3) {
    self.queue = queue
    self.interval = threshold
  }

  
  // MARK: - polling
  // FIXME: some conflation here -- separate polling concerns and op truncation.

  var poller: DispatchSourceTimer?

  
  public func poll() {
    self.poller = periodically(every: self.interval, queue: queue) { [weak self] in
      let op = self?.opOnStandby
      
      self?.opOnStandby = nil
      
      if op != nil { op!() }
    }
  }
  
  public func pollStop() {
    self.poller?.cancel()
    self.poller = nil
  }
  
  open func pollingAsync(closure: @escaping ()->()) {
    queue.async { [unowned self] in
      if self.poller != nil {
        // we are polling, so just drop the op so it picks it up.
        print("will supersede any existing op in \(self)")
        self.opOnStandby = closure
      }
      else {
        self.poll()
        closure()
      }
    }
  }
  
}
