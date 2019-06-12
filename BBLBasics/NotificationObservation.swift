import Foundation



public class NotificationObserver {
  
  let token: Any

  public convenience init(_ notification: NSNotification.Name,
              _ onNotification: @escaping (Notification) -> Void) {
    
    self.init(NotificationCenter.default, notification, onNotification)
  }

  public init(
    _ notificationCentre: NotificationCenter,
    _ notification: NSNotification.Name,
              _ onNotification: @escaping (Notification) -> Void) {
    self.token = notificationCentre.addObserver(forName: notification, object: nil, queue: nil, using: onNotification)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(token)
  }
  
}

