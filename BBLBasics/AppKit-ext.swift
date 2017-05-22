
//
//  AppKit-ext.swift
//  contexter
//
//  Created by Andy Park on 30/06/2016.
//  Copyright © 2016 Big Bear Labs. All rights reserved.
//

import AppKit



extension NSApplication {
  
  public var appSupportDir: URL {
    let appSupportDirUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    return appSupportDirUrl.appendingPathComponent(Bundle.main.bundleIdentifier!)
  }
  
}


public func dispatchAction(_ action: Selector, sender: AnyObject) {
  NSApp.sendAction(action, to: nil, from: sender)
}



extension NSResponder {
  
  public func insertAsNextResponder(_ responder: NSResponder) {
    if responder == self {
      debug("asked to make myself my next responder, doing nothing", #function)
      return
    }
    
    let nextResponder = self.nextResponder
    self.nextResponder = responder
    if nextResponder != nil {
      // recursive.
      responder.insertAsNextResponder(nextResponder!)
    }
  }
  
  private func debug(_ msg: Any?, _ hash_function: String = "", tag: String = "") {
    // TODO impl in a library-suitable way.
  }
  
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
  
  
  // DEPRECATED use `transparant =`
  // RENAME makeTransparent
  public func makeInvisible(_ invisible: Bool = true) {
    if invisible {
      self.backgroundColor = .clear
    }
    
    self.isOpaque = !invisible
    
    let alpha: CGFloat = invisible ? 0 : 1
    self.contentView?.alphaValue = alpha
  }
  
  
  @IBInspectable
  public var transparent: Bool {
    get {
      return
        !self.isOpaque
        && self.backgroundColor == NSColor.clear
    }
    set {
      self.isOpaque = !transparent
      self.backgroundColor = newValue ? NSColor.clear : self.backgroundColor
    }
  }
  
  // NOTE this value, when set on ib, seems to get overwritten.
//  @IBInspectable
  public var isOverlay: Bool {
    get {
      return self.level == Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
    }
    set {
      self.level = Int(CGWindowLevelForKey(newValue ? CGWindowLevelKey.floatingWindow : CGWindowLevelKey.normalWindow))
    }
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



extension CGPoint {
  public func offset(x: CGFloat, y: CGFloat) -> CGPoint {
    return CGPoint(x: self.x + x, y: self.y + y)
  }
}

extension CGRect {
  

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
  
  public enum PinnedEdge {
    case left
    case right
    case top
    case bottom
  }
  
  
  // convert top-y coordinates (Quartz) to bottom-y coordinates (Cocoa).
  public func toCocoaFrame() -> CGRect {
    var frame = self
    frame.origin.y = NSMaxY(NSScreen.screens()![0].frame) - NSMaxY(frame)
    return frame
  }
}


