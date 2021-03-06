
//
//  AppKit-ext.swift
//  contexter
//
//  Created by Andy Park on 30/06/2016.
//  Copyright © 2016 Big Bear Labs. All rights reserved.
//

import AppKit



extension NSApplication {
  
  public var appSupportPathUrl: URL {
    let appSupportDirUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    return appSupportDirUrl.appendingPathComponent(NSRunningApplication.current.bundleIdentifier!)
  }
  
  public var documentsPathUrl: URL {
    let documentsPathUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsPathUrl.appendingPathComponent(NSRunningApplication.current.localizedName!)
  }
  
}



public extension NSResponder {
  
  var responderChain: [NSResponder] {
    
    var chain: [NSResponder] = []
    var responder: NSResponder? = self
    // for windows, track responder chain from its first responder.
    if let w = self as? NSWindow {
      responder = w.firstResponder
    }
    while responder != nil {
      chain.append(responder!)
      responder = responder!.nextResponder
    }
    
    return chain
  }
  
  func insertAsNextResponder(_ responder: NSResponder) {
    if responder == self {
      // asked to make myself my next responder, doing nothing.
      return
    }
    
    let nextResponder = self.nextResponder
    self.nextResponder = responder
    if nextResponder != nil {
      // recursive.
      responder.insertAsNextResponder(nextResponder!)
    }
  }
  
  func dispatch(action: Selector, sender: Any?, target: Any? = nil) {
    // #sendAction scan order according to docs:
    // key window's chain
    // -> key window's delegate's chain
    // -> main window's chain
    // -> main window's delegate's chain
    // -> NSApp's chain
    // -> NSApp's delegate's chain
    let dispatchPath =
      [NSApp.keyWindow?.responderChain as Any, NSApp.keyWindow?.delegate as Any, NSApp.mainWindow?.responderChain as Any, NSApp.mainWindow?.delegate as Any, NSApp.responderChain, NSApp.delegate as Any]
    debug("will dispatch \(action) to the first handling object in chain: \(dispatchPath)")
    
    NSApp.sendAction(action, to: target, from: sender)
  }

  func dispatch(action: Selector, parameters: IBActionParameters, target: Any? = nil) {
    dispatch(action: action, sender: parameters, target: target)
  }
  
}

public protocol IBActionParameters {
}



private func debug(_ msg: Any?, _ hash_function: String = "", tag: String = "") {
  NSLog("\(String(describing: msg))")
  // TODO impl in a library-suitable way.
}


extension NSMenuItem {
  public func performAction() {
    let menu = self.menu
    menu?.performActionForItem(at: menu!.index(of: self))
  }
}



extension NSViewController {
  public func findChildViewController(_ type: AnyClass) -> NSViewController? {
    // try to find match in my children.
    for child in self.childViewControllers {
      if child.isKind(of: type) {
        return child
      }
    }
    
    // recursively call on children.
    for child in self.childViewControllers {
      if let result = child.findChildViewController(type) {
        return result
      }
    }
    
    return nil
  }
}



extension NSWindow {
  
  public var windowFrameView: NSView? {
    return self.contentView?.superview
  }
  
  
  public var titleView: NSView? {
    let superview = self.standardWindowButton(.closeButton)?.superview
    let titleViews = superview?.subviews.filter { $0 is NSTextField }
    return titleViews?.first
  }
  
  
    
  @IBInspectable
  public var transparent: Bool {
    get {
      return
        !self.isOpaque
        && self.backgroundColor == NSColor.clear
    }
    set {
      self.isOpaque = !newValue
      self.backgroundColor = newValue ? NSColor.clear : self.backgroundColor
    }
  }
  
  // NOTE this value, when set on ib, seems to get overwritten.
//  @IBInspectable
  public var isOverlay: Bool {
    get {
      return self.level.rawValue == Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
    }
    set {
      self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(newValue ? CGWindowLevelKey.floatingWindow : CGWindowLevelKey.normalWindow)))
    }
  }
  
  
  public var image: NSImage {
    let windowNumber = UInt32(self.windowNumber)
    if let image = CGWindowListCreateImage(.zero, [.optionIncludingWindow], windowNumber, CGWindowImageOption.nominalResolution) {
      return NSImage(cgImage: image, size: CGSize(width: image.width, height: image.height))
    }
    else {
      fatalError()
    }
  }


  public var diagnosisData: [String : Any] {
    return [
      "windownNumber": self.windowNumber,
      "level": self.level,
      "visible": self.isVisible,
      "alpha": self.alphaValue,
    ]
  }
  
}



extension NSView {
  
  public func addSubview(_ subview: NSView, fit: Bool) {
    self.addSubview(subview)
    if fit {
      subview.frame = self.bounds
    }
  }
  
  public func removeAllSubviews() {
    self.subviews.forEach { $0.removeFromSuperview() }
  }
  
}


public extension NSImage {
  
  convenience init(size: CGSize, drawnAs: () -> ()) {
    self.init(size: size)
    self.lockFocus()
    drawnAs()
    self.unlockFocus()
  }
    
  /// Produce Data from this NSImage with the contained FileType image information.
  /// credit: parrotkit
  func data(for type: NSBitmapImageRep.FileType) -> Data? {
    guard
      let tiff = self.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let dat = rep.representation(using: type, properties: [:])
      else { return nil }
    return dat
  }
  
  var pngRepresentation: Data? {
    return self.data(for: .png)
  }

}

extension Array where Element: NSImage {
  
  public var verticallyTiledImage: NSImage? {
    guard !self.isEmpty else { return nil }
    
    let maxWidth = self.map { $0.size.width } .max()!
    let totalHeight = self.map { $0.size.height } .reduce(0) { acc, height in acc + height }
    
    let frameSize = CGSize(width: maxWidth, height: totalHeight)
    
    let compositedImage = NSImage(size: frameSize) {

      var drawY = frameSize.height
      for image in self {
        autoreleasepool {
          drawY -= image.size.height
          let xForCenteredImage = (frameSize.width - image.size.width) / 2
          let drawOrigin = CGPoint(x: xForCenteredImage, y: drawY)
          image.draw(at: drawOrigin, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
      }
      
    }
    
    return compositedImage
  }
  
}


extension CGPoint {
  public func offset(x: CGFloat, y: CGFloat) -> CGPoint {
    return CGPoint(x: self.x + x, y: self.y + y)
  }
}

extension CGRect {
  
  public init(centre: CGPoint, size: CGSize) {
    let origin = centre.offset(x: -1 * size.width/2, y: -1 * size.height/2)
    self.init(origin: origin, size: size)
  }

  public func modified(delta: CGRect) -> CGRect {
    return CGRect(x: self.x + delta.x, y: self.y + delta.y, width: self.width + delta.width, height: self.height + delta.height)
  }
  
  public var x: CGFloat {
    return self.origin.x
  }
  public var y: CGFloat {
    return self.origin.y
  }
  public var width: CGFloat {
    return self.size.width
  }
  public var height: CGFloat {
    return self.size.height
  }
  
  
  public func widthChangedTo(_ width: CGFloat, pinning: PinnedEdge) -> CGRect {
    let xOffset: CGFloat
    switch pinning {
    case .right:
      xOffset = self.size.width - width
    default:
      xOffset = 0
    }
    
    return CGRect(x: self.origin.x + xOffset, y: self.origin.y, width: width, height: self.size.height)
  }
  
  public func heightChangedTo(_ height: CGFloat, pinning: PinnedEdge) -> CGRect {
    let yOffset: CGFloat
    switch pinning {
    case .top:
      yOffset = self.size.height - height
    default:
      yOffset = 0
    }
    
    return CGRect(x: self.origin.x, y: self.origin.y + yOffset, width: self.size.width, height: height)
  }
  
  public func positioned(relativeTo: CGRect, edge: NSRectEdge) -> CGRect {
    let delta: CGPoint
    switch edge {
    case .maxX:
      delta = CGPoint(x: relativeTo.x + relativeTo.width - self.x, y: relativeTo.y - self.y)
    default:
      fatalError()
    }
    return self.offsetBy(dx: delta.x, dy: delta.y)
  }
  
  
  public enum PinnedEdge {
    case left
    case right
    case top
    case bottom
  }
  
  
  public var centre: CGPoint {
    return self.origin.offset(x: self.size.width/2, y: self.size.height/2)
  }
  
  // convert top-y coordinates (Quartz) to bottom-y coordinates (Cocoa).
  public func toCocoaFrame() -> CGRect {
    var frame = self
    frame.origin.y = NSMaxY(NSScreen.screens[0].frame) - NSMaxY(frame)
    return frame
  }
  
  // for compatibility with JSONEncoder / JSONDecoder.
  public var arrayRepresentation: [[CGFloat]] {
    return [[self.origin.x, self.origin.y], [self.size.width, self.size.height]]
  }

}


