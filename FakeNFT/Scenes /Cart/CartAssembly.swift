import UIKit

public final class CartAssembly {
    
    // MARK: - Dependencies
    private let servicesAssembly: ServicesAssembly
    
    // MARK: - Initialization
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Interface
    public func assemble() -> UIViewController {
        let presenter = makePresenter()
        let viewController = makeViewController(with: presenter)
        configureConnections(presenter: presenter, viewController: viewController)
        
        return viewController
    }
    
    // MARK: - Private Methods
    private func makePresenter() -> CartPresenterImpl {
        CartPresenterImpl(nftService: servicesAssembly.nftService)
    }
    
    private func makeViewController(with presenter: CartPresenter) -> CartViewController {
        CartViewController(presenter: presenter)
    }
    
    private func configureConnections(presenter: CartPresenterImpl, viewController: CartViewController) {
        presenter.view = viewController
    }
}
