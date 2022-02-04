import AppKit


public class PidMatcher {
  let recheckThreshold = 2.0
  
  let bundleId: String

  var lastPidQueryTimestamp: Date?
  var pidsForBundleId: [pid_t] = []

  public init(bundleId: String) {
    self.bundleId = bundleId
  }
  
  public func matches(pid: pid_t) -> Bool {
    if lastPidQueryTimestamp == nil
      || Date().timeIntervalSince(lastPidQueryTimestamp!) > recheckThreshold {
      pidsForBundleId = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).map { $0.processIdentifier }
      lastPidQueryTimestamp = Date()
    }
    
    return pidsForBundleId.contains(pid)
  }
}
