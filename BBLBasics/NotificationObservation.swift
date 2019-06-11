import Foundation



public class NotificationObsevation {
  
  let token: Any
  
  public init(_ notification: NSNotification.Name, _ onNotification: @escaping (Notification) -> Void) {
    self.token = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil, using: onNotification)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(token)
  }
  
}

