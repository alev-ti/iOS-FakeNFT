import UIKit

final class RemoveFromCartAssembly {
    func assemble() -> UIViewController {
        let presenter = RemoveFromCartPresenter()
        let viewController = RemoveFromCartViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}

