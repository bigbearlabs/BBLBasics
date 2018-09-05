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
  
  public func jsonString(options: [JSONSerialization.WritingOptions] = []) throws -> String {
    return String(data: try JSONSerialization.data(withJSONObject: self.jsonObject, options: []), encoding: .utf8)!
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


public extension URL {
  var fileOperations: URLFileOperations {
    return URLFileOperations(url: self)
  }
}

public struct URLFileOperations {
  
  var url: URL
  
}

public extension URLFileOperations {
  
  // MARK: - querying
  
  var isDirectory: Bool {
    if !url.isFileURL { return false }
    do {
      return try FileWrapper(url: url, options: []).isDirectory
    } catch _ {
      return false
    }
  }
    
  var fileExists: Bool {
    return
      url.isFileURL
        && FileManager.default.fileExists(atPath: url.path)
  }
  
  func childUrls(extension: String? = nil) throws -> [URL] {
    guard url.isFileURL else {
      return []
    }
    return try FileManager.default.contentsOfDirectory(atPath: url.path)
      .map { url.appendingPathComponent($0) }
      .filter { `extension` != nil ? $0.pathExtension == `extension` : true }
  }
  
  
  // MARK: - aliasing
    
  func isAliasFor(destination: URL) throws -> Bool {
    if self.fileExists {
      let bookmarkData = try URL.bookmarkData(withContentsOf: url)
      var bookmarkDataIsStale: Bool = false
      let destinationUrl = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale)
      
      return
        destinationUrl?.isEquivalent(toUrl: destination) == true
    }
    return false
  }
    
  func createAsAliasFor(destination: URL) throws {
    let bookmarkData = try destination.bookmarkData(options: .suitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeTo: nil)
    
    try URL.writeBookmarkData(bookmarkData, to: url)
  }
 
  
  // MARK: - file access
  
  func write(data: Data?, completionHandler: (Error?) -> ()) {
    let parent = self.url.deletingLastPathComponent()
    if !parent.fileOperations.fileExists {
      parent.fileOperations.createDirectory()
    }
    guard parent.fileOperations.isDirectory else {
//      completionHandler(error)  // TODO
      fatalError()
    }
    
    try! data?.write(to: self.url, options: [])
    
    // TODO errors
    
    completionHandler(nil)
  }
  
  func read(completionHandler: (Data, Error?) -> ()) {
    fatalError("not implemented!")
  }
  
  func createDirectory() {
    try! FileManager.default.createDirectory(at: self.url, withIntermediateDirectories: true, attributes: [:])
  }
}




@objc(Iso8601ToLocalDateTransformer)
@available(OSX 10.13, *)
open class Iso8601ToLocalDateTransformer: ValueTransformer {
  
  override open func transformedValue(_ value: Any?) -> Any? {
    if let iso8601String = value as? String {
      let f = ISO8601DateFormatter()
      guard let date = f.date(from: iso8601String) else {
        return nil
      }
      
      // format into a human-friendly string.
      let f2 = DateFormatter()
      f2.timeStyle = .medium
      f2.dateStyle = .medium
      f2.formattingContext = .listItem
      f2.doesRelativeDateFormatting = true
      return f2.string(from: date)
    }

    return nil
  }
  
}

