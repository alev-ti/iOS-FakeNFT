import UIKit
import ProgressHUD

protocol CartView: UIViewController, LoadingView {
    func toggleEmptyCartView(show: Bool)
    func updateCollectionView()
    func configurePrice(with total: Double, nftsCount: Int)
    func performBatchUpdate(deletionAt indexPath: IndexPath, completion: @escaping () -> Void)
    func performBatchUpdate(moveFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath], completion: @escaping () -> Void)
    func setupNavigationBarForNextScreen()
    func showAlert(_ alert: AlertModel)
}

final class CartViewController: UIViewController, CartView {
    
    // MARK: - Constants
    
    enum Constants {
        static let filterButtonIcon = "sort_icon"
        static let deleteNftIcon = "delete_icon"
        static let nftStubImage = "nft_stub"
        static let costString = NSLocalizedString("Cart.price", comment: "")
        static let payButtonString = NSLocalizedString("Cart.toPayment", comment: "")
        static let emptyCartLabelString = NSLocalizedString("Cart.cartIsEmpty", comment: "")
    }
    
    // MARK: - Properties
    
    let presenter: CartPresenterProtocol
    
    private lazy var screenWidth = UIScreen.main.bounds.width
    private lazy var multiplierForView = screenWidth / 375.0
    
    private let cellIdentifier = "CartCell"
    private let itemsPerRow: CGFloat = 1
    private let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    private let interItemSpacing: CGFloat = 0
    private var cellHeight: CGFloat = 0
    
    // MARK: - UI Components
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var emptyCartLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bold17
        label.textColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .yaBlackDark : .yaBlackLight
        }
        return label
    }()
    
    private lazy var buttonPanelView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .yaLightGrayDark : .yaLightGrayLight
        }
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .yaBlackDark : .yaBlackLight
        }
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.bold17
        button.setTitleColor(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .yaWhiteDark : .yaWhiteLight
        }, for: .normal)
        return button
    }()
    
    private lazy var nftCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.regular15
        label.textColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .yaBlackDark : .yaBlackLight
        }
        return label
    }()
    
    private lazy var totalCostLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bold17
        label.textColor = .yaGreenUniversal
        return label
    }()
    
    // MARK: - Initialization
    
    init(presenter: CartPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
    }
    
    // MARK: - Public Methods
    
    func toggleEmptyCartView(show: Bool) {
        collectionView.isHidden = show
        buttonPanelView.isHidden = show
        navigationController?.navigationBar.isHidden = show
        emptyStateView.isHidden = !show
    }
    
    func configurePrice(with total: Double, nftsCount: Int) {
        totalCostLabel.text = "\(String(format: "%.2f", total)) ETH"
        nftCountLabel.text = "\(nftsCount) NFT"
    }
    
    func updateCollectionView() {
        collectionView.reloadData()
    }
    
    func performBatchUpdate(deletionAt indexPath: IndexPath, completion: @escaping () -> Void) {
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }, completion: { _ in
            completion()
        })
    }
    
    func performBatchUpdate(moveFrom fromIndexPaths: [IndexPath], to toIndexPaths: [IndexPath], completion: @escaping () -> Void) {
        collectionView.performBatchUpdates({
            for (fromIndexPath, toIndexPath) in zip(fromIndexPaths, toIndexPaths) {
                self.collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
            }
        }, completion: {_ in
            completion()
        })
    }
    
    func setupNavigationBarForNextScreen() {
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButton
        navigationController?.navigationBar.tintColor = UIColor.dynamicBlack
    }
    
    func showAlert(_ alert: AlertModel) {
        let alertController = alert.makeAlertController()
        self.present(alertController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupLoadingView()
        setupNavigationBar()
        setupCollectionView()
        setupButtonPanel()
    }
    
    private func setupLoadingView() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = nil
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        let filterButton = UIBarButtonItem(
            image: UIImage(named: Constants.filterButtonIcon),
            style: .done,
            target: self,
            action: #selector(filterButtonTapped)
        )
        filterButton.tintColor = .iconButton
        navigationItem.rightBarButtonItem = filterButton
    }
    
    private func setupCollectionView() {
        collectionView.register(CartCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        emptyCartLabel.text = Constants.emptyCartLabelString
        emptyStateView.addSubview(emptyCartLabel)
        NSLayoutConstraint.activate([
            emptyCartLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyCartLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor)
        ])
        
        view.addSubview(emptyStateView)
        emptyStateView.isHidden = true
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupButtonPanel() {
        payButton.setTitle(Constants.payButtonString, for: .normal)
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        buttonPanelView.isHidden = true
        
        buttonPanelView.addSubview(payButton)
        buttonPanelView.addSubview(nftCountLabel)
        buttonPanelView.addSubview(totalCostLabel)
        
        NSLayoutConstraint.activate([
            payButton.topAnchor.constraint(equalTo: buttonPanelView.topAnchor, constant: 16),
            payButton.bottomAnchor.constraint(equalTo: buttonPanelView.bottomAnchor, constant: -16),
            payButton.leadingAnchor.constraint(greaterThanOrEqualTo: buttonPanelView.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: buttonPanelView.trailingAnchor, constant: -16),
            payButton.widthAnchor.constraint(equalToConstant: 240 * multiplierForView),
            
            nftCountLabel.topAnchor.constraint(equalTo: buttonPanelView.topAnchor, constant: 16),
            nftCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: buttonPanelView.bottomAnchor, constant: -16),
            nftCountLabel.leadingAnchor.constraint(equalTo: buttonPanelView.leadingAnchor, constant: 16),
            nftCountLabel.trailingAnchor.constraint(greaterThanOrEqualTo: payButton.trailingAnchor, constant: -16),
            
            totalCostLabel.topAnchor.constraint(greaterThanOrEqualTo: nftCountLabel.bottomAnchor, constant: 2),
            totalCostLabel.bottomAnchor.constraint(equalTo: buttonPanelView.bottomAnchor, constant: -16),
            totalCostLabel.leadingAnchor.constraint(equalTo: buttonPanelView.leadingAnchor, constant: 16),
            totalCostLabel.trailingAnchor.constraint(greaterThanOrEqualTo: payButton.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(buttonPanelView)
        NSLayoutConstraint.activate([
            buttonPanelView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonPanelView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonPanelView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            buttonPanelView.heightAnchor.constraint(equalToConstant: 76)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func filterButtonTapped() {
        presenter.filterButtonTapped()
    }
    
    @objc private func payButtonTapped() {
        presenter.paymentButtonTapped()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension CartViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.getNFTs()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        ) as? CartCell, let nfts = presenter.getNFTs() else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: nfts[indexPath.row], stubImage: UIImage(named: Constants.nftStubImage))
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left + sectionInsets.right + interItemSpacing * (itemsPerRow - 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem = widthPerItem * (140 / 375)
        cellHeight = heightPerItem
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
}

// MARK: - CartCellDelegate

extension CartViewController: CartCellDelegate {
    func didTapButton(on cell: CartCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        presenter.removeButtonTapped(at: indexPath)
    }
}
