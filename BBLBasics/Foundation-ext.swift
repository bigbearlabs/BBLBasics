//
//  Foundation-ext.swift
//  contexter
//
//  Created by Andy Park on 27.10.16.
//  Copyright © 2016 Big Bear Labs. All rights reserved.
//

import Foundation



extension String {
  
  // RENAME urlCompatibleString
  public var encodedString: String {
    get {
      return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
  }
  
  // FIXME
  public func indented(level: Int, spaces: Int = 2) -> String {
    var indentation = ""
    (0...(level * spaces)).forEach { _ in
      indentation.append(" ")
    }
    return
      self
        .replacingOccurrences(of: "\n", with: "\(indentation)\n")
  }
}


extension Array {
  
  public func onlyElementMatching(allowNoMatch: Bool = false, filter: (Element) -> Bool) -> Element? {
    let matches = self.filter(filter)
    if matches.count != 1 {
      if matches.count == 0 && allowNoMatch {
        // no matches and caller specified this will be alloed.
        return nil
      } else {
        fatalError("no matches in \(self) for \(filter)")
      }
    }
    return matches[0]
  }
}



extension Dictionary {
  
  mutating func filterSelf( includeElement: (Dictionary.Iterator.Element) throws -> Bool) rethrows -> () {
    for (k, v) in self {
      if try !includeElement((k, v)) { self.removeValue(forKey: k) }
    }
  }
  
}



extension URL {
  
  public init?(string: String, ensureScheme: Bool) {
    guard string.characters.count > 0 else {
      return nil
    }
    
    let i = string.characters.index(string.startIndex, offsetBy: 1)
    if ensureScheme && string[..<i] == "/" {
      // we have a file path.
      self.init(string: "file://\(string.encodedString)")
      return
    }
    
    self.init(string: string)
  }
  
}



extension Date {

  var iso8601: String {
    return DateFormatter.string(date: self).copy() as! String
  }
  
}



extension NSObject {
  
  public func notifyValueChange(forKey key: String, op: (() -> ())? = nil) {
    self.willChangeValue(forKey: key)
    if op != nil {
      op!()
    }
    self.didChangeValue(forKey: key)
  }
  
}


// MARK: app-level.

public extension NSUserNotification {
  
  // stolen from https://github.com/vojto/NiceKit/blob/a7487c32e80b16d0ded8095c3366e7c29cfae917/Pod/Classes/Mac/NSUserNotification%2BAdditions.swift
  public static func deliver(_ title: String, text: String) {
    let center = NSUserNotificationCenter.default
    let notification = NSUserNotification()
    
    notification.title = title
    notification.informativeText = text
    center.deliver(notification)
  }
  
}


