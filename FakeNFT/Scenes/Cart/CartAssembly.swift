import UIKit

final class CartAssembly {
    
    // MARK: - Dependencies
    private let servicesAssembly: ServicesAssembly
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Interface
    func assemble() -> UIViewController {
        let presenter = makePresenter()
        let viewController = makeViewController(with: presenter)
        configureConnections(presenter: presenter, viewController: viewController)
        
        return viewController
    }
    
    // MARK: - Private Methods
    private func makePresenter() -> CartPresenter {
        CartPresenter(nftService: servicesAssembly.nftService, serviceAssembly: servicesAssembly)
    }
    
    private func makeViewController(with presenter: CartPresenterProtocol) -> CartViewController {
        CartViewController(presenter: presenter)
    }
    
    private func configureConnections(presenter: CartPresenter, viewController: CartViewController) {
        presenter.view = viewController
    }
}
