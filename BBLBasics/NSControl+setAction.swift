import AppKit


public protocol NSControlActionFunctionProtocol {}

public extension NSControlActionFunctionProtocol where Self: NSControl {
    func setAction(action: @escaping (Self) -> Void) {
      let trampoline = ActionTrampoline(action: action)
      self.target = trampoline
      self.action = #selector(ActionTrampoline<Self>.action(sender:))
      objc_setAssociatedObject(self, &NSControlActionFunctionProtocolAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
    }
}


extension NSControl: NSControlActionFunctionProtocol {}


class ActionTrampoline<T>: NSObject {
  var action: (T) -> Void

  init(action: @escaping (T) -> Void) {
    self.action = action
  }

  @objc func action(sender: NSControl) {
    action(sender as! T)
  }
}


private var NSControlActionFunctionProtocolAssociatedObjectKey = "NSControlActionFunctionProtocolAssociatedObjectKey"

