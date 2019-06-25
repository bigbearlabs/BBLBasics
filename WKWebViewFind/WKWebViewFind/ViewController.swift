//
//  ViewController.swift
//  WKWebViewFind
//
//  Created by ilo on 24/06/2019.
//  Copyright © 2019 Big Bear Labs. All rights reserved.
//

import Cocoa
import WebKit


// NOTE
// as of 20190624, WKWebView does not expose the NSTextFinderClient interface.
// we may be able to make a conformance by coordinating calls to either a webkit 2 SPI,
// or a private interface.
// but it's probably not worth doing so until MiniBrowser shows correct behaviour.
// check updates of https://bugs.webkit.org/show_bug.cgi?id=191702 before resuming.

class ViewController: NSViewController {

  @IBOutlet weak var webView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
//    webView.loadHTMLString("<html><body>hello world</body></html>", baseURL: nil)
    webView.load(URLRequest(url: URL(string: "https://start.duckduckgo.com")!))
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }


  @IBAction
  func action_doit(_ s: Any?) {
    
  }
}


extension WKWebView: NSTextFinderClient {
  
}


