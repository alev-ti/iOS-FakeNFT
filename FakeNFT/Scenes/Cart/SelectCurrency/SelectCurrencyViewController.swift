import UIKit

protocol SelectCurrencyViewProtocol: UIViewController, LoadingView {
    func updateCollectionView()
    func toggleSelectAtCell(at indexPath: IndexPath, isSelected: Bool)
    func updatePayButtonState(_ isCurrencySelected: Bool)
    func showAlert(_ alert: AlertModel)
}

final class SelectCurrencyViewController: UIViewController {
    private enum Constants {
        static let title = "Выбор способа оплаты"
        static let userAgreementText = "Совершая покупку, вы соглашаетесь с условиями Пользовательского соглашения"
        static let userAgreementLinkText = "Пользовательского соглашения"
        static let userAgreementLinkURL = "https://ya.ru"
        static let paymentButtonText = "Оплатить"
        static let buttonBlockHeight: CGFloat = 184
        static let paymentButtonHeight: CGFloat = 60
        static let itemAspectRatio: CGFloat = 46/168
    }
    
    private struct Layout {
        static let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let interItemSpacing: CGFloat = 7
        static let verticalItemSpacing: CGFloat = 7
        static let itemsPerRow: CGFloat = 2
    }
    
    let presenter: SelectCurrencyPresenterProtocol
    private var lastSelectedCell: IndexPath?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Layout.interItemSpacing
        layout.minimumLineSpacing = Layout.verticalItemSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CurrencyCell.self, forCellWithReuseIdentifier: CurrencyCell.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var userAgreementTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = []
        textView.attributedText = makeUserAgreementAttributedText()
        return textView
    }()
    
    private lazy var userAgreementBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .dynamicLightGray
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var paymentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .dynamicBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold17
        button.setTitleColor(.dynamicWhite, for: .normal)
        button.setTitle(Constants.paymentButtonText, for: .normal)
        button.addTarget(self, action: #selector(didPayButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(presenter: SelectCurrencyPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter.viewDidLoad()
    }
    
    @objc private func didPayButtonTapped() {
        presenter.payOrder(with: Array(CartStore.cartItemIDs))
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = Constants.title
        
        setupLoadingView()
        setupCollectionView()
        setupButtonPanel()
        updatePayButtonState(false)
    }
    
    private func setupLoadingView() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupButtonPanel() {
        view.addSubview(userAgreementBackgroundView)
        userAgreementBackgroundView.addSubview(userAgreementTextView)
        userAgreementBackgroundView.addSubview(paymentButton)
        
        NSLayoutConstraint.activate([
            userAgreementBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            userAgreementBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            userAgreementBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            userAgreementBackgroundView.heightAnchor.constraint(equalToConstant: Constants.buttonBlockHeight),
            
            userAgreementTextView.bottomAnchor.constraint(equalTo: userAgreementBackgroundView.bottomAnchor, constant: -4),
            userAgreementTextView.leadingAnchor.constraint(equalTo: userAgreementBackgroundView.leadingAnchor, constant: 16),
            userAgreementTextView.trailingAnchor.constraint(equalTo: userAgreementBackgroundView.trailingAnchor, constant: -16),
            userAgreementTextView.topAnchor.constraint(equalTo: userAgreementBackgroundView.topAnchor, constant: 16),
            
            paymentButton.bottomAnchor.constraint(equalTo: userAgreementBackgroundView.bottomAnchor, constant: -48),
            paymentButton.leadingAnchor.constraint(equalTo: userAgreementBackgroundView.leadingAnchor, constant: 12),
            paymentButton.trailingAnchor.constraint(equalTo: userAgreementBackgroundView.trailingAnchor, constant: -12),
            paymentButton.heightAnchor.constraint(equalToConstant: Constants.paymentButtonHeight)
        ])
    }
    
    private func makeUserAgreementAttributedText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: Constants.userAgreementText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        attributedString.addAttributes([
            .font: UIFont.regular13,
            .foregroundColor: UIColor.dynamicBlack,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributedString.length))
        
        let linkRange = (Constants.userAgreementText as NSString).range(of: Constants.userAgreementLinkText)
        attributedString.addAttributes([
            .link: Constants.userAgreementLinkURL,
            .foregroundColor: UIColor.yaBlueUniversal
        ], range: linkRange)
        
        return attributedString
    }
}

extension SelectCurrencyViewController: SelectCurrencyViewProtocol {
    func updateCollectionView() {
        collectionView.reloadData()
    }
    
    func toggleSelectAtCell(at indexPath: IndexPath, isSelected: Bool) {
        (collectionView.cellForItem(at: indexPath) as? CurrencyCell)?.toggleSelectState(isSelected)
    }
    
    func showAlert(_ alert: AlertModel) {
        present(alert.makeAlertController(), animated: true)
    }
    
    func updatePayButtonState(_ isCurrencySelected: Bool) {
        paymentButton.isEnabled = isCurrencySelected
        paymentButton.backgroundColor = isCurrencySelected ?
            .dynamicBlack.withAlphaComponent(1.0) :
            .dynamicBlack.withAlphaComponent(0.5)
    }
}

extension SelectCurrencyViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrencyCell.reuseIdentifier, for: indexPath)
        (cell as? CurrencyCell)?.configure(with: presenter.currencies[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = Layout.sectionInsets.left + Layout.sectionInsets.right + Layout.interItemSpacing * (Layout.itemsPerRow - 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / Layout.itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem * Constants.itemAspectRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lastSelectedCell.map { toggleSelectAtCell(at: $0, isSelected: false) }
        presenter.currencyDidSelect(at: indexPath)
        lastSelectedCell = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        Layout.sectionInsets
    }
}
