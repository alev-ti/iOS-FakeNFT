import UIKit

final class SelectCurrencyAssembly {

    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }

    public func assemble() -> UIViewController {
        let presenter = SelectCurrencyPresenter(currencyService: servicesAssembly.currencyService)
        
        let viewController = SelectCurrencyViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
