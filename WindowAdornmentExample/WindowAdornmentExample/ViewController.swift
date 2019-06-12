//
//  ViewController.swift
//  WindowAdornmentExample
//
//  Created by ilo on 12/06/2019.
//  Copyright © 2019 Big Bear Labs. All rights reserved.
//

import Cocoa
import BBLBasics



class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func viewDidAppear() {
    super.viewDidAppear()

    showAll()
  }

  func showAll() {
    subjectWindow = window()
    subjectWindow.makeKeyAndOrderFront(nil)
    
    adornment = Adornment(
      subject: subjectWindow,
      image: NSImage(named: NSImage.advancedName)!,
      anchor: self.view)
    
    adornmentRenderer = WindowAdornmentRenderer(a: adornment)
    adornmentRenderer.render()
  }
  
  var subjectWindow: NSWindow!
  var adornment: Adornment!
  var adornmentRenderer: WindowAdornmentRenderer!
  
  
  @IBAction
  func action_render(_ sender: Any?) {
    adornmentRenderer.render()
    let diag = [
      "subject frame": subjectWindow.frame,
      "anchor frame": adornment.anchor.frameInCanvasCoordinates
    ]
    print("subject frame: \(diag)")
  }
  
  @IBAction
  func action_toggle(_ s: Any?) {
    adornmentRenderer.isVisible = !adornmentRenderer.isVisible
  }
}

