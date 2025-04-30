import UIKit

protocol RemoveFromCartViewProtocol: UIViewController {
    func configureScreen(with nft: Nft)
    var onConfirm: (() -> Void)? { get set }
}

final class RemoveFromCartViewController: UIViewController, RemoveFromCartViewProtocol {
    let presenter: RemoveFromCartPresenterProtocol
    var onConfirm: (() -> Void)?
    
    private enum Constants {
        static let labelText = Localizable.RemoveFromCart.labelText
        static let removeBtnText = Localizable.RemoveFromCart.removeBtnText
        static let returnBtnText = Localizable.RemoveFromCart.returnBtnText
    }
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var returnButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .dynamicBlack
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .regular17
        button.setTitleColor(.dynamicWhite, for: .normal)
        return button
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .dynamicBlack
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .regular17
        button.setTitleColor(.yaRedUniversal, for: .normal)
        return button
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regular13
        label.textColor = .dynamicBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.backgroundColor = UIColor.red.cgColor
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurEffect)
        view.frame = self.view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    init(presenter: RemoveFromCartPresenterProtocol) {
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
        setupConstraints()
        configureScreen()
    }
    
    func configureScreen(with nft: Nft = Nft()) {
        textLabel.text = Constants.labelText
        returnButton.setTitle(Constants.returnBtnText, for: .normal)
        removeButton.setTitle(Constants.removeBtnText, for: .normal)
        guard let imageUrl = nft.images.first else { return }
        nftImageView.kf.setImage(with: imageUrl)
    }
    
    @objc private func didCancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func didRemoveButtonTapped(_ sender: UIButton) {
        onConfirm?()
        dismiss(animated: true)
    }
    
    private func setupViews() {
        view.addSubview(blurEffectView)
        view.addSubview(nftImageView)
        view.addSubview(textLabel)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(removeButton)
        buttonsStackView.addArrangedSubview(returnButton)
        
        returnButton.addTarget(self, action: #selector(didCancelButtonTapped), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(didRemoveButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nftImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: ScreenMetrics.height * -0.1),
            nftImageView.widthAnchor.constraint(equalToConstant: 108 * ScreenMetrics.scaleFactor),
            nftImageView.heightAnchor.constraint(equalTo: nftImageView.widthAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 12 * ScreenMetrics.scaleFactor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 97 * ScreenMetrics.scaleFactor),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -97 * ScreenMetrics.scaleFactor),
            
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20 * ScreenMetrics.scaleFactor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 58 * ScreenMetrics.scaleFactor),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -58 * ScreenMetrics.scaleFactor),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 44 * ScreenMetrics.scaleFactor)
        ])
    }
}
