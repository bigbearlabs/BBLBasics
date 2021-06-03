open class StatusItemController {
  
  let image: NSImage
  
  let onClick: () -> ()
  
  
  private lazy var statusItem: NSStatusItem = {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    item.button?.image = self.image
    
    item.button?.target = self
    item.button?.action = #selector(action_buttonClicked(_:))
    
    item.highlightMode = true
    
    return item
  }()
  
  
  public init(image: NSImage, onClick: @escaping () -> ()) {
    
    self.image = image
    self.onClick = onClick
    
    _ = self.statusItem
  }
  
  public var menu: NSMenu? {
    get {
      return self.statusItem.menu
    }
    set {
      self.statusItem.menu = newValue
    }
  }
  
  @IBAction
  func action_buttonClicked(_ sender: NSButton) {
    onClick()
  }
  
  
  
  
  public var view: NSView? {
    return self.statusItem.button
  }
  
}

