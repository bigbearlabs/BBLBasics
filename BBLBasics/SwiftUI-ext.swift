import SwiftUI



@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    func applyIf<T: View>(_ condition: @autoclosure () -> Bool, apply: (Self) -> T) -> AnyView {
        if condition() {
            return apply(self).erase()
        } else {
            return self.erase()
        }
    }
  
  func erase() -> AnyView {
    return AnyView(self)
  }
}



public extension View {
  func showIf(_ condition: @autoclosure () -> Bool) -> AnyView {
    if !condition() {
      return self.hidden().erase()
    }
    return self.erase()
  }
}



@available(macOS 12.0, *)
public extension Color {
  init?(data: Data) {
    guard let colour = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    else { return nil }
    self.init(nsColor: colour)
  }
  
  var data: Data {
    guard let cgColor = self.cgColor,
            let nsColour = NSColor(cgColor: cgColor)
    else { fatalError() }
    
    let data = try! NSKeyedArchiver.archivedData(withRootObject: nsColour, requiringSecureCoding: false)
    return data
  }
}
