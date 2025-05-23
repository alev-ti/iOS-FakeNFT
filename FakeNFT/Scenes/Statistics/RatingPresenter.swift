import UIKit

protocol RatingPresenterProtocol {
    func viewDidLoad()
    func didTapSort()
}

final class RatingPresenter: RatingPresenterProtocol {
    
    private weak var view: RatingViewProtocol?
    private let userService: UserServiceProtocol
    private var users: [RatingViewModel] = []
    private var currentSort: SortOption = .ranking
    
    init(view: RatingViewProtocol, userService: UserServiceProtocol) {
        self.view = view
        self.userService = userService
    }
    
    func viewDidLoad() {
        
        if let saved = UserDefaults.standard.string(forKey: "StatisticsSortOption"),
           let opt = SortOption.allCases.first(where: { $0.title == saved }) {
            currentSort = opt
        }
        loadUsers()
    }
    
    func didTapSort() {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        SortOption.allCases.forEach { option in
            alert.addAction(.init(title: option.title, style: .default) { [weak self] _ in
                self?.applySort(option)
            })
        }
        alert.addAction(.init(title: "Отмена", style: .cancel))
        view?.showSortAlert(alert)
    }
    
    private func loadUsers() {
        view?.showLoading(true)
        userService.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                switch result {
                case .success(let rawUsers):
                    self?.users = rawUsers.enumerated().map { idx, u in
                        RatingViewModel(
                            id: u.id,                   
                            rank: idx + 1,
                            name: u.name,
                            nftCount: u.nfts.count,
                            avatarURL: URL(string: u.avatar ?? "")
                        )
                    }
                    self?.applySort(self?.currentSort ?? .ranking)
                case .failure(let err):
                    self?.view?.showError(err.localizedDescription)
                }
            }
        }
    }
    
    private func applySort(_ option: SortOption) {
        currentSort = option
        // Сохраняем выбор
        UserDefaults.standard.set(option.title, forKey: "StatisticsSortOption")
        
        switch option {
        case .name:
            users.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .ranking:
            users.sort { $0.rank < $1.rank }
        }
        view?.showUsers(users)
    }
}


private enum SortOption: CaseIterable {
    case name, ranking
    var title: String {
        switch self {
        case .name:     return "По имени"
        case .ranking:  return "По рейтингу"
        }
    }
}
