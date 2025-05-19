import UIKit

final class TabBarController: UITabBarController {
    
    var servicesAssembly: ServicesAssembly!
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let cartTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.cart", comment: ""),
        image: UIImage(named: "tab_bar_cart_inactive"),
        selectedImage: UIImage(named: "tab_bar_cart_active")
    )
    
    
    private let statsTabBarItem = UITabBarItem(
        title: NSLocalizedString("Статистика", comment: ""),
        image: UIImage(named: "flag_inactive"),
        selectedImage: UIImage(named: "flag_active")
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setupViewControllers()
    }
    
    private func configureAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupViewControllers() {
        
        let catalogViewController = makeCatalogViewController()
        catalogViewController.tabBarItem = catalogTabBarItem
        
       
        let cartViewController = makeCartViewController()
        cartViewController.tabBarItem = cartTabBarItem
        
       
        let statsNav = RatingAssembly.build()
        statsNav.tabBarItem = statsTabBarItem
        
        viewControllers = [
            catalogViewController,
            cartViewController,
            statsNav
        ]
    }
    
    private func makeCatalogViewController() -> UIViewController {
        let controller = TestCatalogViewController(servicesAssembly: servicesAssembly)
        return controller
    }
    
    private func makeCartViewController() -> UIViewController {
        let assembly = CartAssembly(servicesAssembly: servicesAssembly)
        let controller = assembly.assemble()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
