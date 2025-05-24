import UIKit

final class UserCollectionViewController: UIViewController, UserCollectionViewProtocol {
    var presenter: UserCollectionPresenterProtocol!
    var ownerId: String!
    
    private var items: [NftViewModel] = []
    
    private lazy var spinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 28
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.register(
            UserCollectionCell.self,
            forCellWithReuseIdentifier: UserCollectionCell.reuseID
        )
        cv.dataSource = self
        cv.delegate   = self
        return cv
    }()
    
    override func viewDidLoad() {
        hidesBottomBarWhenPushed = true
        super.viewDidLoad()
        title = "Коллекция NFT"
        view.backgroundColor = .white
        setupNavBar()
        
        view.addSubview(collectionView)
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(onBack)
        )
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func showLoading(_ isLoading: Bool) {
        spinner.isHidden = !isLoading
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
        collectionView.isHidden = isLoading
    }
    
    func showNfts(_ items: [NftViewModel]) {
        self.items = items
        collectionView.reloadData()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}


extension UserCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let vm = items[indexPath.item]
        guard let cell = cv.dequeueReusableCell(
            withReuseIdentifier: UserCollectionCell.reuseID,
            for: indexPath
        ) as? UserCollectionCell else {
            fatalError("Unable to dequeue UserCollectionCell")
        }
        cell.configure(with: vm)

        cell.onCartToggle = { [weak self] in
            self?.presenter.didToggleCart(nftId: vm.id)
        }
        cell.onLikeToggle = { [weak self] in
            self?.presenter.didToggleLike(nftId: vm.id)
        }
        return cell
    }
}


extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    private var cellsPerRow: Int { return 3 }
    private var cellWidth: CGFloat { return 108 }
    private var cellHeight: CGFloat { return 172 }
    private var gap: CGFloat { return 8 }
    private var sectionTop: CGFloat { return 20 }
    private var sectionBottom: CGFloat { return 16 }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return gap
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCells = CGFloat(cellsPerRow) * cellWidth
        let totalGaps = CGFloat(cellsPerRow - 1) * gap
        let collectionWidth = collectionView.bounds.width
        let horizontalInset = max((collectionWidth - totalCells - totalGaps) / 2, 0)
        return UIEdgeInsets(top: sectionTop, left: horizontalInset, bottom: sectionBottom, right: horizontalInset)
    }
}
