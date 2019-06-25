//: A Cocoa based Playground to present user interface

import AppKit
import WebKit
import PlaygroundSupport

let nibFile = NSNib.Name("MyView")
var topLevelObjects : NSArray?

Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }

// Present the view in Playground
PlaygroundPage.current.liveView = views[0] as! NSView

let v = (views[0] as! NSView).subviews[0] as! WKWebView
v.loadHTMLString("hello", baseURL: nil)

type(of: v)

extension WKWebView: NSTextFinderClient {
  
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
  let v2 = v as! NSTextFinderClient
//  print(
    [
      v2.string,
      v2.stringLength?(),
      v2.isSelectable
      ] as [Any]
//  )
}

PlaygroundPage.current.needsIndefiniteExecution = true

//1
