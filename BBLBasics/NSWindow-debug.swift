import AppKit
import OSLog



//private var logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "<no-bundle-id>", category: "BBLBasics.debug")
// TODO catch up after merging in changes from Zen.

public extension NSWindow {
  
  @IBAction
  func action_debugPrintKeyViews(_ sender: Any) {
    guard let keyView = firstResponder as? NSView else {
      print("DEBUG: first responder \(firstResponder?.description) not an NSView")
      return
    }
    
    let nextKeyView = keyView.nextKeyView
    
    print("DEBUG key views: \((keyView, nextKeyView))")
  }
  
  @IBAction
  func action_debugPrintResponders(_ sender: Any) {
    let first = firstResponder
    let next = first?.nextResponder
    
    print("DEBUG first 2 responders: \((first, next))")
  }
  
}
