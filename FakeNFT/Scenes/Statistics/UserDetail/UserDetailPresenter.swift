import UIKit

final class UserDetailPresenter: UserDetailPresenterProtocol {
    
    private weak var view: UserDetailViewProtocol?
    private let service: UserServiceProtocol
    private let userId: String
    private var userModel: UserDetailViewModel?
    
    init(view: UserDetailViewProtocol,
         service: UserServiceProtocol,
         userId: String) {
        self.view   = view
        self.service = service
        self.userId = userId
    }
    
    func viewDidLoad() {
        view?.showLoading(true)
        service.fetchUser(id: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.view?.showLoading(false)
                switch result {
                case .success(let dto):
                    let vm = UserDetailViewModel(
                        id: dto.id,
                        name: dto.name,
                        avatarURL: dto.avatar.flatMap { URL(string: $0) },
                        description: dto.description ?? "",
                        websiteURL: dto.website.flatMap { URL(string: $0) },
                        nftCount: dto.nfts.count
                    )
                    self.userModel = vm
                    self.view?.showUser(vm)
                    
                case .failure(let error):
                    self.view?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    func didTapWebsite() {
        guard let url = userModel?.websiteURL else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func didTapCollection() {
        // Навигация на экран коллекции будет реализована в эпике 3
    }
}
