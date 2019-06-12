//: A Cocoa based Playground to present user interface

import AppKit
import PlaygroundSupport
import BBLBasics



let nibFile = NSNib.Name("MyView")
var topLevelObjects : NSArray?

Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }

// Present the view in Playground
let canvas = views[0] as! NSView
PlaygroundPage.current.liveView = canvas




func randomFrame(max: CGRect) -> CGRect {
  return [
    CGRect(x: 10, y: 100, width: 122, height: 344),
    CGRect(x: 0, y: 0, width: 122, height: 75),
    CGRect(x: 304, y: 40, width: 88, height: 45),
    ].randomElement()!
}


extension NSView: AdornmentSubject {
  
  public var proposedFrame: CGRect {
    get {
      return self.frame
    }
    set {
      if self.frame != newValue {
        self.frame = newValue
      }
    }
  }
  
  public var isVisible: Bool {
    return !self.isHidden
  }
  
  public func setIsVisible(_ visible: Bool) {
    self.isHidden = !visible

  }
}

extension NSView: AdornmentAnchor {
  public var frameInCanvasCoordinates: CGRect {
    return self.frame
  }
}


// grab the text label to use as the anchor.
let anchorView = canvas.subviews[0]

// place a subject view in the canvas.
//let subject = NSButton(title: "Subject", target: nil, action: nil)
let subject = NSBox(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
subject.boxType = .custom
subject.title = "A adornment subject"
subject.fillColor = .yellow
canvas.addSubview(subject)


// TMP verify frame manipulation is sane.
//button.frame = CGRect(x: canvas.bounds.maxX - 100, y: canvas.bounds.maxY - 100, width: button.frame.width, height: button.frame.height)

let adornment = Adornment(
  subject: subject,
  image: NSImage(named: NSImage.cautionName)!,
  anchor: anchorView)


// this strategy consumes adornment data to render in a view.
class ViewAdornmentRenderer {
  let a: Adornment
  
  let canvas: NSView
  
  init(a: Adornment, view: NSView) {
    self.a = a
    self.canvas = view
    
    _ = self.observations
  }
  
  lazy var observations: Any = {
    let subject = a.subject as! NSView
    
    return (
      // track anchor properties.
      anchorView.observe(\.frame) { [unowned self] v, c in
        self.render()
      }
      ,
      // track subject properties.
      subject.observe(\.frame) { [unowned self] v, c in
        self.render()
    })
  }()
  
  
  func render() {
    
    // reposition the subject.
    var subject = a.subject
    subject.proposedFrame = a.subjectFrame
    
    // place the image.
    imageView.frame = a.imageFrame
    canvas.addSubview(imageView)
  }
  
  var isVisible = true {
    didSet {
      var subject = a.subject
      subject.setIsVisible(self.isVisible)
      self.imageView.isHidden = !self.isVisible
    }
  }
  
  
  lazy var imageView = { () -> NSImageView in
    let content = self.a.image
    return NSImageView(image: content)
  }()
  
}


let renderStrategy = ViewAdornmentRenderer(a: adornment, view: canvas)
renderStrategy.render()


// sketch out a window render strategy.
//struct WindowRenderStrategy {
//
//  mutating func render(_ a: Adornment) {
//    // reposition the subject.
//    var subject = a.subject
//    subject.proposedFrame = a.subjectFrame
//
//    // frame the image in a window and place it.
//    if self.imageWindow == nil {
//      self.imageWindow = imageWindow(image: a.image)
//    }
//    self.imageWindow.setFrame(a.imageFrame, display: true)
//
//    // TODO add image window as child of subject?
//  }
//
//
//  func imageWindow(image: NSImage) -> NSWindow {
//    let imageView = NSImageView(image: image)
//    let window: NSWindow // STUB
//    window.contentView = imageView
//    return window
//  }
//
//  var imageWindow: NSWindow!
//}


let toggleButtonHolder = ButtonHolder(title: "toggle") { b in
  renderStrategy.isVisible = !renderStrategy.isVisible
}
canvas.addSubview(toggleButtonHolder.button)

let moveAnchorButtonHolder = ButtonHolder(title: "move anchor") { b in
  anchorView.frame = anchorView.frame.offsetBy(dx: 20, dy: 0)
}
moveAnchorButtonHolder.button.shiftBy(dx: toggleButtonHolder.button.frame.width, dy: 0)
canvas.addSubview(moveAnchorButtonHolder.button)

let resizeSubjectButtonHolder = ButtonHolder(title: "resize subject") { b in
  subject.frame = randomFrame(max: canvas.frame)
}
resizeSubjectButtonHolder.button
  .shiftBy(dx: toggleButtonHolder.button.frame.width, dy: 0)
  .shiftBy(dx: moveAnchorButtonHolder.button.frame.width, dy: 0)

canvas.addSubview(resizeSubjectButtonHolder.button)



