import Foundation


protocol UserDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapWebsite()
    func didTapCollection()
}

protocol UserDetailViewProtocol: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showUser(_ user: UserDetailViewModel)
    func showError(_ message: String)
}

struct UserDetailViewModel {
    let id: String
    let name: String
    let avatarURL: URL?
    let description: String
    let websiteURL: URL?
    let nftCount: Int
}
