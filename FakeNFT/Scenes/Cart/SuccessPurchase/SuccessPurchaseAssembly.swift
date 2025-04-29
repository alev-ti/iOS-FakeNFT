import UIKit

final class SuccessPurchaseAssembly {
    func assemble() -> UIViewController {
        let presenter = SuccessPurchasePresenter()
        let viewController = SuccessPurchaseViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
