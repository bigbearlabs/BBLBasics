import Foundation


@discardableResult
public func synchronised<T>(obj: AnyObject, handler: () throws -> T) rethrows -> T {
  objc_sync_enter(obj)
  defer { objc_sync_exit(obj) }
  return try handler()
}


// TODO timer potentially prevents sleep -- mitigate.
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
  timer.schedule(deadline: start, repeating: DispatchTimeInterval.seconds(Int(interval)), leeway: DispatchTimeInterval.seconds(0))
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



open class LastOnlyQueue {  // RENAME polling queue.
  
  let queue: DispatchQueue
  let interval: TimeInterval
  
  var opOnStandby: (()->())?
  
  public init(queue: DispatchQueue = DispatchQueue(label: "\(NSRunningApplication.current.bundleIdentifier!).LastOnlyQueue"), threshold: TimeInterval = 3) {
    self.queue = queue
    self.interval = threshold
  }

  
  // MARK: - polling
  // FIXME: some conflation here -- separate polling concerns and op truncation.

  var poller: DispatchSourceTimer?

  
  public func poll() {
    self.poller = periodically(every: self.interval, queue: queue) { [weak self] in
      let op = self?.opOnStandby
      
      if op != nil { op!() }
    }
  }
  
  public func pollStop() {
    self.poller?.cancel()
    self.poller = nil
  }
  
  
  open func async(closure: @escaping ()->()) {
    self.pollingAsync { [unowned self] in
      closure()
      self.pollStop()
    }
  }
  
  open func pollingAsync(closure: @escaping ()->()) {
    queue.async { [unowned self] in
      if self.poller != nil {
        fatalError("bad call")
      }
      else {
        self.opOnStandby = closure
        self.poll()
        // first run.
        closure()
      }
    }
  }
  
}



extension DispatchSource {
  
  /// convenience method for the the timer that takes a block and makes it tick before returning it.
  static public func timerWithBlock(deadline: DispatchTime, queue: DispatchQueue, repeating: TimeInterval? = nil, block: @escaping () -> ()) -> DispatchSourceTimer {
    let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
    
    if let repeating = repeating {
      timer.schedule(deadline: deadline, repeating: DispatchTimeInterval.seconds(Int(repeating)), leeway: DispatchTimeInterval.seconds(0))
    } else {
      timer.schedule(deadline: deadline)
    }
  
    timer.setEventHandler(handler: block)
  
    timer.resume()

    return timer
  }
}



public class QueuePool {
  
  var queues: [DispatchQueue] = []
  
  public var currentQueue: DispatchQueue {
    return queues.last!
  }
  
  public init() {
    self.addQueue()
  }
  
  
  public func addQueue() {
    let newQueue = DispatchQueue(label: "\(self)_\(Date())" )
    
    queues.append(newQueue)
    
  }
  
}



public class QuotaBasedQueue {

  /// maximum number of operations to be in-flight.
  /// any operations for the same id dispatched when quota exceeded will have its fallback
  /// closure executed instead.
  let quota: Int

  
  var inFlightCountsByOperationId: [String : Int] = [:]
  
  
  let queue: DispatchQueue
  
  
  public init(quota: Int, queue: DispatchQueue) {
    self.quota = quota
    self.queue = queue
  }
  
  
  public func async(
    operationId: String,
    operation: @escaping () -> Void,
    whenQuotaExhausted: @escaping () -> Void) {
    
    self.queue.async { [unowned self] in
      
      let count = self.inFlightCountsByOperationId[operationId] ?? 0
      guard count < self.quota else {
        // in flight quota is exhausted, will execute the fallback closure instea.
        
        whenQuotaExhausted()
        
        return
      }
     
      self.inFlightCountsByOperationId[operationId] = count + 1
      
      operation()

      self.inFlightCountsByOperationId[operationId] = count
    }
  }
  
}

