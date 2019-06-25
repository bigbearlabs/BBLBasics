import Cocoa



public func viewController(view: NSView? = nil) -> NSViewController {
  let view = view ?? NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 400))
  
  let vc = NSViewController(nibName: nil, bundle: nil)
  vc.view = view
  return vc
}


public func windowController() -> NSWindowController {
  return NSWindowController(window: window())
}


public func window() -> NSWindow {
  
  // Window size
  let windowRect = NSRect(x: 30, y: 30, width: 400, height: 400)
  
  let window = NSWindow(contentRect: windowRect, styleMask: [.titled], backing: .buffered, defer: false)
  
  // Configure window here
  // Content view
  let viewRect = NSRect(x: 0, y: 0, width: 300, height: 300)
  let view = NSView(frame: viewRect)
  
  // configure your content view and add subviews here
  let textField = NSTextField(frame: NSRect(x: 30, y: 30, width: 100, height: 20))
  
  textField.stringValue = "Test"
  
  view.addSubview(textField)
  
  let button = NSButton(frame: NSRect(x: 30, y: 60, width: 100, height: 30))
  
  button.highlight(true)
  button.bezelStyle = .rounded
  
  view.addSubview(button)
  
  window.contentView?.addSubview(view)
  
  return window
}



public class ButtonHolder {
  public var button: NSButton!
  let onClick: (Any?) -> Void
  
  public init(title: String, onClick: @escaping (Any?) -> Void) {
    self.onClick = onClick
    let button = NSButton(title: title, target: self, action: #selector(buttonClicked(_:)))
    self.button = button
  }
  
  @IBAction func buttonClicked(_ sender: Any?) {
    self.onClick(sender)
  }
}
