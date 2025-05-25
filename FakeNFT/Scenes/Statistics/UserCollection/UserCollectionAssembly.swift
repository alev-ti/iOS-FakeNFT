import UIKit

enum UserCollectionAssembly {
    static func build(ownerId: String) -> UIViewController {
        guard
            let tab = UIApplication.shared
                        .connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?
                        .windows
                        .first?
                        .rootViewController as? TabBarController,
            let services = tab.servicesAssembly
        else {
            fatalError("Не удалось получить servicesAssembly")
        }

        let view = UserCollectionViewController()
        view.ownerId = ownerId

    
        let service = services.nftService

        let presenter = UserCollectionPresenter(
            view:    view,
            service: service,
            ownerId: ownerId
        )
        view.presenter = presenter

        return view
    }
}
