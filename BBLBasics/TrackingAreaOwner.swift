//
//  TrackingAreaOwner.swift
//  BBLBasics
//
//  Created by ilo on 10/02/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import AppKit



/// allows creating tracking areas with closures.
class TrackingAreaOwner: NSView {
  let handlers: [NSEventType:()->Void]
  
  convenience init?(view: NSView, handlers: [NSEventType:()->Void]) {
    self.init(coder: NSArchiver(), handlers: handlers)
    
    let rect = view.bounds  // superseded by .inVisibleRect
    let options: NSTrackingAreaOptions = [.inVisibleRect, .mouseEnteredAndExited, .activeAlways]
    let area = NSTrackingArea(rect: rect, options: options, owner: self, userInfo:nil)
    view.addTrackingArea(area)
  }
  
  init?(coder: NSCoder, handlers: [NSEventType:()->Void]) {
    self.handlers = handlers
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func mouseEntered(with event: NSEvent) {
    maybeInvokeHandler(event.type)
  }
  override func mouseExited(with event: NSEvent) {
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
