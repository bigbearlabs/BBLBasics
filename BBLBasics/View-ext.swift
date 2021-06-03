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



