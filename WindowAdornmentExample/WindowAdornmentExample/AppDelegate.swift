import Cocoa
import BBLBasics




@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}


extension NSWindow: AdornmentSubject {
  
  public var proposedFrame: CGRect {
    get {
      return self.frame
    }
    set {
      self.setFrame(newValue, display: self.isVisible)
    }
  }
  
}

extension NSView: AdornmentAnchor {
  public var frameInCanvasCoordinates: CGRect {
    let window = self.window!
   let viewBoundsInWindow = self.convert(self.bounds, to: nil)
    return window.convertToScreen(viewBoundsInWindow)
  }
}


// this strategy consumes adornment data to render in a view.
class WindowAdornmentRenderer {
  
  let a: Adornment
  
  
  init(a: Adornment) {
    self.a = a
    
    _ = self.observations
  }
  
  lazy var observations: Any = {
    let subject = a.subject as! NSWindow
    
    return (
//      // track anchor properties.
//      anchorWindow.observe(\.frame) { [unowned self] v, c in
//        self.render()
//      },
      
      // track subject properties.
      subject.observe(\.frame) { [unowned self] v, c in
        self.render()
      }
    )
  }()
  
  
  func render() {
    
    // reposition the subject.
    let subject = a.subject as! NSWindow
    subject.proposedFrame = a.subjectFrame
    subject.orderFront(self)
    
    // place the image.
    let imageFrame = a.imageFrame
    imageWindow.setFrame(imageFrame, display: true)
    
    let anchorWindow = (a.anchor as! NSView).window!
    
    // ensure positions are tracked.
    anchorWindow.addChildWindow(self.imageWindow, ordered: .above)
    anchorWindow.addChildWindow(subject, ordered: .above)
  }
  
  var isVisible = true {
    didSet {
      let subject = a.subject
      subject.setIsVisible(self.isVisible)
      self.imageWindow.setIsVisible(
        self.isVisible)

      if self.isVisible {
        self.render()
      }
    }
  }
  
  
  lazy var imageWindow = { () -> NSWindow in
    let content = self.a.image
    let imageView = NSImageView(image: content)
    let _window = window()
    _window.contentView = imageView
    _window.orderFront(self)
    return _window
  }()
  
}
