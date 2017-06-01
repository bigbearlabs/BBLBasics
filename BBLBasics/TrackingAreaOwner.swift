//
//  TrackingAreaOwner.swift
//  BBLBasics
//
//  Created by ilo on 10/02/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import AppKit



/// allows creating tracking areas with closures.
public class TrackingAreaOwner: NSResponder {
  
  var trackingArea: NSTrackingArea!
  let handlers: [NSEventType:()->Void]
  
  public init?(view: NSView, handlers: [NSEventType:()->Void]) {
    self.handlers = handlers
    super.init()
    
    let rect = view.bounds  // superseded by .inVisibleRect option.
    let options: NSTrackingAreaOptions = [.inVisibleRect, .mouseEnteredAndExited, .activeAlways]
    trackingArea = NSTrackingArea(rect: rect, options: options, owner: self, userInfo:nil)
    
    view.addTrackingArea(trackingArea)
  }
  
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
