//
//  Foundation-ext.swift
//  contexter
//
//  Created by Andy Park on 27.10.16.
//  Copyright © 2016 Big Bear Labs. All rights reserved.
//

import Foundation



extension String {
  
  public var queryEncodedString: String {
    return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
  }
  
  public var queryDecodedString: String {
    return self.removingPercentEncoding!
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
  
  public var firstAndOnly: Element? {
    guard self.count <= 1 else {
      fatalError()
    }
    
    return self.first
  }
  
}



extension Dictionary {
  
  mutating public func filterSelf( includeElement: (Dictionary.Iterator.Element) throws -> Bool) rethrows -> () {
    for (k, v) in self {
      if try !includeElement((k, v)) { self.removeValue(forKey: k) }
    }
  }
  
}



extension URL {
  
  public static func from(string: String, queryParameters: [String : String]) -> URL? {
    var components = URLComponents(string: string)!
    components.queryItems = queryParameters.map { k, v in
      URLQueryItem(name: k, value: v)
    }
    return components.url
  }
  

  public init?(string: String, ensureScheme: Bool) {
    guard string.count > 0 else {
      return nil
    }
    
    let i = string.index(string.startIndex, offsetBy: 1)
    if ensureScheme && string[..<i] == "/" {
      // we have a file path.
      self.init(string: "file://\(string.queryEncodedString)")
      return
    }
    
    self.init(string: string)
  }
  
  public var isFolder: Bool {
    if !self.isFileURL { return false }
    do {
      return try FileWrapper(url: self, options: []).isDirectory
    } catch _ {
      return false
    }
  }
  
  
  public func isEquivalent(toUrl url: URL) -> Bool {
    return self == url
      // trailing slashes should not affect equivalence.
      || self.appendingPathComponent("") == url.appendingPathComponent("")
  }
  
  
  public func queryItem(name: String) -> URLQueryItem? {
    if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems,
      let queryItem = queryItems
        .first(where: { $0.name == name }) {
      return queryItem
    }
    return nil
  }

}

public extension Array where Element == URL {
  
  public func isEquivalent(toUrls urls: [URL]) -> Bool {
    guard self.count == urls.count else {
      return false
    }
    
    let nonEquivalentItems = self.enumerated().filter { element -> Bool in
      let (i, url) = element
      return !url.isEquivalent(toUrl: urls[i])
    }
    
    return nonEquivalentItems.isEmpty
  }
  
}

extension Date {

  public var iso8601: String {
    if #available(OSX 10.13, *) {
      return ISO8601DateFormatter.string(from: self, timeZone: TimeZone.current, formatOptions: [.withInternetDateTime, .withFractionalSeconds])
    } else {
      // Fallback on earlier versions TODO
      fatalError()
    }
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



extension Encodable {
  
  public var jsonObject: Any {
    return autoreleasepool { () -> Any in
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      let encodedData = try! encoder.encode(self)
      let jsonObject = try! JSONSerialization.jsonObject(
        with: encodedData)
      return jsonObject
    }
  }
  
}



// MARK: - app-level.

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



public extension FileManager {
  
  public func directoryExists(atPath path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    _ = fileExists(atPath: path, isDirectory: &isDirectory)
    return isDirectory.boolValue
  }
  
  public func childUrls(of directoryUrl: URL, extension: String) throws -> [URL] {
    guard directoryUrl.isFileURL else {
      return []
    }
    return try FileManager.default.contentsOfDirectory(atPath: directoryUrl.path)
      .map { directoryUrl.appendingPathComponent($0) }
      .filter { $0.pathExtension == `extension` }
  }
  
}



