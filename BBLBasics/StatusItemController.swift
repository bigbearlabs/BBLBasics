open class StatusItemController: NSObject { // for nib-based menu loading.
  
  let image: NSImage?
  
  @IBOutlet public var menu: NSMenu?

  var onClick: () -> Void = {}
  let onRightClick: () -> Void
  
  private lazy var statusItem: NSStatusItem = {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    item.button?.image = self.image
    
    item.button?.target = self
    item.button?.action = #selector(action_buttonClicked(_:))
    item.button?.sendAction(on: [.leftMouseDown, .rightMouseDown])

    // ensure no menu on item, to allow right-clicks.
    item.menu = nil
    
    return item
  }()
  
  
  @available(*, deprecated)
  public init(
    image: NSImage?,
    menu: NSMenu? = nil,
    onClick: (() -> Void)? = nil,
    onRightClick: @escaping () -> Void = {}) {
        
    self.image = image
    self.menu = menu
    self.onRightClick = onRightClick
    
    super.init()

    self.onClick = onClick
      ?? { [unowned self] in
        if let menu = self.menu {
          self.statusItem.popUpMenu(menu)
        }
      }
    
    _ = self.statusItem
  }
  
  
  @IBAction
  func action_buttonClicked(_ sender: NSButton) {

    guard let currentEvent = NSApp.currentEvent else {
        return
    }

    switch currentEvent.type {
    case .leftMouseDown:
      onClick()
      
    case .rightMouseDown:
      onRightClick()
      
    default: ()
    }

  }

  
  public var view: NSView? {
    return self.statusItem.button
  }
  
}

