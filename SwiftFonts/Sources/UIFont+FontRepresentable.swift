import Foundation
import UIKit




extension UIFont {

    /// Create a UIFont object with a `Font` enum
    public convenience init?<T: FontRepresentable>(font: T, size: CGFloat) {
        
        self.init(name: font.rawValue, size: size)
    }

}

