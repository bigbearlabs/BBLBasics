public struct Adornment {
  
  public var subject: AdornmentSubject
  public let image: NSImage
  public var anchor: AdornmentAnchor
  
  public init(subject: AdornmentSubject, image: NSImage, anchor: AdornmentAnchor) {
    self.subject = subject
    self.image = image
    self.anchor = anchor
  }
  
  public var imageFrame: CGRect {
    return CGRect(origin: subject.frame.topLeft, size: adornmentSize)
      .offsetBy(dx: adornmentXOffset, dy: 0)
  }
  
  public var subjectFrame: CGRect {
    return subject.frame
      .offsetTopLeft(to: anchor.frameInCanvasCoordinates.origin)
      .offsetBy(dx: 0, dy: -1 * adornmentSize.height)
  }
  
  
  let adornmentSize = CGSize(width: 10, height: 10)
  let adornmentXOffset: CGFloat = 12.0
}



public protocol AdornmentSubject {
  var frame: CGRect { get }
  var proposedFrame: CGRect { get set }
  
  var isVisible: Bool { get }
  func setIsVisible(_ visible: Bool)
}

public protocol AdornmentAnchor {
  var frameInCanvasCoordinates: CGRect { get }
}

