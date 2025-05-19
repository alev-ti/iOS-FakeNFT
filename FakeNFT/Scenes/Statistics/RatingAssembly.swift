import UIKit

enum RatingAssembly {
    
    static func build() -> UIViewController {
        
        let view = RatingViewController()
        
        
        guard
            let baseURLString = Bundle.main.object(forInfoDictionaryKey: "PracticumBaseURL") as? String,
            let baseURL       = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)),
            let token         = Bundle.main.object(forInfoDictionaryKey: "PracticumMobileToken") as? String
        else {
            fatalError("Не найдены PracticumBaseURL или PracticumMobileToken в Info.plist")
        }
        
        
        let userService = UserService(baseURL: baseURL, token: token)
        let presenter   = RatingPresenter(view: view, userService: userService)
        view.presenter  = presenter
        
        
        let nav = UINavigationController(rootViewController: view)
        nav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Статистика", comment: ""),
            image: UIImage(named: "flag_inactive"),
            selectedImage: UIImage(named: "flag_active")
        )
        return nav
    }
}
