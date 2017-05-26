//
//  KeyViewManaging.swift
//  BBLBasics
//
//  Created by ilo on 27/05/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

import Foundation



public protocol KeyViewManaging {
  var keyView: NSView? { get }
}

extension KeyViewManaging {
  public func makeKeyViewFirstResponder(window: NSWindow) {
    
    window.makeFirstResponder(self.keyView!)
  }
}
