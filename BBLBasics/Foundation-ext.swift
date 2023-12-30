//
//  Foundation-ext.swift
//  contexter
//
//  Created by Andy Park on 27.10.16.
//  Copyright © 2016 Big Bear Labs. All rights reserved.
//

import Foundation
import OrderedCollections



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


// https://stackoverflow.com/questions/29365145/how-can-i-encode-a-string-to-base64-in-swift
public extension String {
  /// Encode a String to Base64
  func toBase64() -> String {
    return Data(self.utf8).base64EncodedString()
  }
  
  /// Decode a String from Base64. Returns nil if unsuccessful.
  func fromBase64() -> String? {
    guard let data = Data(base64Encoded: self) else { return nil }
    return String(data: data, encoding: .utf8)
  }
}



public extension Array {
  
  var firstAndOnly: Element? {
    guard self.count <= 1 else {
      fatalError()
    }
    
    return self.first
  }
  
  
  func containsAll(_ array: [Element]) -> Bool where Element: Equatable {
    for e in array {
      if !self.contains(e) {
        return false
      }
    }
    return true
  }

  
  func index(after i: Int, looping: Bool) -> Int {
    if self.count == 0 {
      return 0
    }
    if looping {
      let index = i < self.count - 1 ? i + 1 : 0
      return index
    }
    return self.index(after: i)
  }
  
  func index(before i: Int, looping: Bool) -> Int {
    if self.count == 0 {
      return 0
    }
    if looping {
      let index = i > 0 ? i - 1 : self.count - 1
      return index
    }
    return self.index(before: i)
  }
  
  
  func removing(at indexes: [Int]) -> Array {
    guard !isEmpty else { return self }
    let newIndexes = Set(indexes).sorted(by: >)
    var newVal = self
    newIndexes.forEach {
      guard $0 < count, $0 >= 0 else { return }
      newVal.remove(at: $0)
    }
    return newVal
  }
  
  func toDictionary<Key>(key: (Self.Element) -> Key) -> [Key : Self.Element] {
    Dictionary(uniqueKeysWithValues: self.map { elem in
      (key(elem), elem)
    })
  }
}



public extension Array where Array.Element: Equatable & Hashable {
  
  var uniqueValues: [Element] {
    OrderedSet(self).elements
  }
  
}

public extension Array where Array.Element: Equatable {
  
  var uniqueValues: [Element] {
    self.reduce([]) { r, e in
      if r.contains(e) {
        return r
      } else {
        return r + [e]
      }
    }
  }
  
}



extension Dictionary {
  
  mutating public func filterSelf( includeElement: (Dictionary.Iterator.Element) throws -> Bool) rethrows -> () {
    for (k, v) in self {
      if try !includeElement((k, v)) { self.removeValue(forKey: k) }
    }
  }
  
}



public extension URL {
  
  static func from(string: String, queryParameters: [String : String]) -> URL? {
    var components = URLComponents(string: string)!
    components.queryItems = queryParameters.map { k, v in
      URLQueryItem(name: k, value: v)
    }
    return components.url
  }
  

  init?(string: String, ensureScheme: Bool) {
    guard string.count > 0 else {
      return nil
    }
    
    let i = string.index(string.startIndex, offsetBy: 1)
    if ensureScheme && string[..<i] == "/" {
      // we have a file path.
      self.init(string: "file://" + string.queryEncodedString)
      return
    }
    
    self.init(string: string)
    return
  }
  
  func isEquivalent(toUrl url: URL) -> Bool {
    return self == url
      // trailing slashes should not affect equivalence.
      // also compare the strings to work around some mysterious equality failure cases seen in the wild.
      || self.appendingPathComponent("").absoluteString == url.appendingPathComponent("").absoluteString
  }
  
  
  func queryItem(name: String) -> URLQueryItem? {
    if let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems,
      let queryItem = queryItems
        .first(where: { $0.name == name }) {
      return queryItem
    }
    return nil
  }

  var removingTrailingSlash: URL {
    var str = self.absoluteString
    if str.reversed().starts(with: "/") {
      str.removeLast()
      return URL(string: str)!
    }
    return self
  }
}

public extension Array where Element == URL {
  
  func isEquivalent(toUrls urls: [URL]) -> Bool {
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
  
  // MARK: kvc
  
  public func notifyValueChange(forKey key: String, op: (() -> ())? = nil) {
    self.willChangeValue(forKey: key)
    if op != nil {
      op!()
    }
    self.didChangeValue(forKey: key)
  }
  
  
  // MARK: associated objects
  
  /// get an associated object for `key`, or creates and sets according to `init`.
  /// `key` must be a static member to ensure uniqueness.
  public func associatedObject<T: NSObject>(key: UnsafeRawPointer, owner: Any? = nil, init: () -> T) -> T {
    let owner = owner ?? self
    
    if let storedObject = objc_getAssociatedObject(owner, key) {
      return storedObject as! T
    }
    else {
      let obj = `init`()
      objc_setAssociatedObject(owner, key, obj, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
      return obj
    }
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
  static func deliver(_ title: String, text: String) {
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
    do {
      return try (self.fileExists
        && FileWrapper(url: url, options: []).isDirectory)
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
        destinationUrl.isEquivalent(toUrl: destination) == true
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
    
    var err: Error? = nil
    do {
      if !parent.fileOperations.fileExists {
        try parent.fileOperations.createDirectory()
      }
      guard parent.fileOperations.isDirectory else {
        fatalError()
      }
      
      try data?.write(to: self.url, options: [])
    }
    catch let e {
      err = e
    }
    
    completionHandler(err)
  }
  
  func read(completionHandler: (Data, Error?) -> ()) {
    fatalError("not implemented!")
  }
  
  func createDirectory() throws {
    try FileManager.default.createDirectory(at: self.url, withIntermediateDirectories: true, attributes: [:])
  }
  
  func hideExtension() throws {
    try FileManager.default.setAttributes([
        FileAttributeKey.extensionHidden : true
      ],
      ofItemAtPath: self.url.path)
  }
  
  // MARK: -
  
  func ensureAsDirectory() throws {
    if self.isDirectory {
      return
    }
    
    guard !self.fileExists else {
      fatalError() // TODO throw instead.
    }
    
    try self.createDirectory()
  }
  
  func showInFinder() {
    NSWorkspace.shared.activateFileViewerSelecting([self.url])
    
    // FIXME when url already shown in a finder window in another space, this can silently do nothing.
    // best way to handle this is probably to bring-to-space when necessary.
  }
}




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



public extension Bundle {
  // Name of the app - title under the icon.
  var displayName: String {
    return FileManager.default.displayName(atPath: self.bundleURL.path)
  }
}



public extension Sequence {
  
  func reject(_ isExcluded: (Element) -> Bool) -> [Element] {
    return self.filter {
      isExcluded($0) == false
    }
  }
  
}


// MARK: -


public extension Array where Element: Equatable {
  
  /// return an array sorted by sorting the results of `evaluatingElementsBy` to `sortedArray`.
  ///
  /// if `sortedArray` is empty, returns an array in identical order to self.
  ///
  /// if element to evaluate is not present in sorted array, element is pushed back.
  func sorted<Value: Comparable>(sortedArray: [Value], evaluatingElementsBy: (Element) -> Value ) -> Array<Element> {
    guard !sortedArray.isEmpty else {
      return self
    }
    let tuples = self.map { ($0, evaluatingElementsBy($0)) }
    let sortedTuples = tuples.sorted {
      let (elemA, evalA) = $0
      let (elemB, evalB) = $1

      switch (sortedArray.firstIndex(of: evalA), sortedArray.firstIndex(of: evalB)) {
      case let (i1?, i2?):
        // sort by index in sorted array.
        return i1 < i2
      case (nil, nil):
        // sort by index in self.
        return self.firstIndex(of: elemA)! < self.firstIndex(of: elemB)!
      case (nil, _):
        // prefer the non-nil.
        return false
      case (_, nil):
        // prefer the non-nil.
        return true
      default: fatalError()
      }
    }
    
    return sortedTuples.map { $0.0 }
  }
  
}

