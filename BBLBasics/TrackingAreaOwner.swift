//
//  TrackingAreaOwner.swift
//  BBLBasics
//
//  Created by ilo on 10/02/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import AppKit



/// allows creating tracking areas with closures.
public class TrackingAreaOwner: NSView {
  let handlers: [NSEventType:()->Void]
  var trackingArea: NSTrackingArea?
  convenience public init?(view: NSView, handlers: [NSEventType:()->Void]) {
    self.init(coder: NSArchiver(), handlers: handlers)
  }
  
  init?(coder: NSCoder, handlers: [NSEventType:()->Void]) {
    self.handlers = handlers
    self.trackingArea = nil
    super.init(frame: .zero)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func updateTrackingAreas() {
    let rect = self.bounds  // superseded by .inVisibleRect
    let options: NSTrackingAreaOptions = [.inVisibleRect, .mouseEnteredAndExited, .activeAlways]
    if self.trackingArea != nil {
      self.removeTrackingArea(trackingArea!)
    }
    self.trackingArea = NSTrackingArea(rect: rect, options: options, owner: self, userInfo:nil)
    self.addTrackingArea(self.trackingArea!)
  }
  override public func mouseEntered(with event: NSEvent) {
    maybeInvokeHandler(event.type)
  }
  override public func mouseExited(with event: NSEvent) {
    maybeInvokeHandler(event.type)
  }
  
  func maybeInvokeHandler(_ eventType: NSEventType) {
    guard let handler = handlers[eventType] else {
      // debug("\(self) did't register handler for type \(eventType)")
      return
    }
    
    handler()
  }
  
}
