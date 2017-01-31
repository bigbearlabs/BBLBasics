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



open class LastOnlyQueue {
  
  let queue: DispatchQueue
  
  var opOnStandby: (()->())?
  var poller: DispatchSourceTimer!
  
  public init(queue: DispatchQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).LastOnlyQueue")) {
    self.queue = queue
    
    // ensure the queue is operational when it's created.
    self.resume()
  }
  
  func resume(threshold: TimeInterval = 3) {
    self.poller = periodically(every: 3, queue: queue) { [weak self] in
      let op = self?.opOnStandby
      
      self?.opOnStandby = nil
      
      if op != nil { op!() }
    }
  }
  
  open func async(closure: @escaping ()->()) {
    queue.async { [unowned self] in
      if self.opOnStandby != nil {
        print("will supersede op.")
      }
      
      self.opOnStandby = closure
    }
  }
}
