import UIKit

enum UserDetailAssembly {
    
    static func build(with model: RatingViewModel) -> UIViewController {
        let vc = UserDetailViewController(model: model)
        return vc
    }
}
