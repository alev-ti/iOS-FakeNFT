// Scenes/Statistics/RatingViewController.swift

import UIKit


protocol RatingViewProtocol: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showUsers(_ users: [RatingViewModel])
    func showError(_ message: String)
    func showSortAlert(_ alert: UIAlertController)
}


struct RatingViewModel {
    let rank: Int
    let name: String
    let nftCount: Int
    let avatarURL: URL?
}

final class RatingViewController: UIViewController {
    
    
    var presenter: RatingPresenterProtocol!
    
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var users: [RatingViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupActivityIndicator()
        setupSortButton()
        
        presenter.viewDidLoad()
    }
    
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        tableView.register(RatingCell.self, forCellReuseIdentifier: RatingCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top:0, left:16, bottom:0, right:16)
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupSortButton() {
        let img = UIImage(named: "sort_icon")?
            .withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: img,
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
    }
    
    @objc private func sortButtonTapped() {
        presenter.didTapSort()
    }
}


extension RatingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RatingCell.reuseIdentifier,
            for: indexPath
        ) as? RatingCell else {
            return UITableViewCell()
        }
        
        let vm = users[indexPath.row]
        cell.configure(with: vm)
        return cell
    }
}


extension RatingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vm = users[indexPath.row]
        // Переходим на экран информации о пользователе
        let detailVC = UserDetailAssembly.build(with: vm)
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



extension RatingViewController: RatingViewProtocol {
    
    func showLoading(_ isLoading: Bool) {
        activityIndicator.isHidden = !isLoading
        tableView.isHidden = isLoading
        if isLoading { activityIndicator.startAnimating() }
        else { activityIndicator.stopAnimating() }
    }
    
    func showUsers(_ users: [RatingViewModel]) {
        self.users = users
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Ошибка", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: NSLocalizedString("ОК", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
    func showSortAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}
