import Foundation
import UIKit

final class ScreenMetrics {
    static let designWidth: CGFloat = 375.0
    
    static var width: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        UIScreen.main.bounds.height
    }
    
    static var scaleFactor: CGFloat {
        width / designWidth
    }
}

