import UIKit

enum UserDetailAssembly {
    static func build(userId: String) -> UIViewController {
        let view = UserDetailViewController()
        
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "PracticumBaseURL") as? String,
            let baseURL   = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)),
            let token     = Bundle.main.object(forInfoDictionaryKey: "PracticumMobileToken") as? String
        else {
            fatalError("Не найдены PracticumBaseURL или PracticumMobileToken в Info.plist")
        }
        
        let service   = UserService(baseURL: baseURL, token: token)
        let presenter = UserDetailPresenter(view: view,
                                            service: service,
                                            userId: userId)
        view.presenter = presenter
        
        return view
    }
}
