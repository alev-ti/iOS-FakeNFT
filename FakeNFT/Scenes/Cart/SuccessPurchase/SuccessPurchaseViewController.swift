import UIKit
import Kingfisher

protocol SuccessPurchaseViewProtocol: UIViewController {
    var onConfirm: (() -> Void)? { get set }
    func updateNftImage(_ image: UIImage?)
    func loadNftImage(_ url: URL?)
}

final class SuccessPurchaseViewController: UIViewController {
    private enum Constants {
        static let text = "Успех! Оплата прошла, поздравляем с покупкой!"
        static let returnButtonText = "Вернуться в каталог"
        static let imageSize: CGFloat = 278
        static let buttonHeight: CGFloat = 60
        static let verticalOffset: CGFloat = -0.1
    }
    
    private let presenter: SuccessPurchasePresenterProtocol
    var onConfirm: (() -> Void)?
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .bold22
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .dynamicBlack
        label.text = Constants.text
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .dynamicBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold17
        button.setTitleColor(.dynamicWhite, for: .normal)
        button.setTitle(Constants.returnButtonText, for: .normal)
        button.addTarget(self, action: #selector(didDoneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(presenter: SuccessPurchasePresenterProtocol) {
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
        presenter.loadNftImage()
    }
    
    @objc private func didDoneButtonTapped() {
        onConfirm?()
        presenter.onDoneButtonTapped()
    }
}

extension SuccessPurchaseViewController: SuccessPurchaseViewProtocol {
    func updateNftImage(_ image: UIImage?) {
        nftImageView.image = image
    }
    
    func loadNftImage(_ url: URL?) {
        nftImageView.kf.setImage(with: url)
    }
}

private extension SuccessPurchaseViewController {
    func setupViews() {
        view.backgroundColor = .systemBackground
        [nftImageView, textLabel, doneButton].forEach(view.addSubview)
        
        NSLayoutConstraint.activate([
            nftImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nftImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: ScreenMetrics.height * Constants.verticalOffset
            ),
            nftImageView.heightAnchor.constraint(
                equalToConstant: Constants.imageSize * ScreenMetrics.scaleFactor
            ),
            nftImageView.widthAnchor.constraint(equalTo: nftImageView.heightAnchor),
            
            textLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 36 * ScreenMetrics.scaleFactor
            ),
            textLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -36 * ScreenMetrics.scaleFactor
            ),
            textLabel.topAnchor.constraint(
                equalTo: nftImageView.bottomAnchor,
                constant: 20 * ScreenMetrics.scaleFactor
            ),
            
            doneButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16 * ScreenMetrics.scaleFactor
            ),
            doneButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16 * ScreenMetrics.scaleFactor
            ),
            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16 * ScreenMetrics.scaleFactor
            ),
            doneButton.heightAnchor.constraint(
                equalToConstant: Constants.buttonHeight * ScreenMetrics.scaleFactor
            )
        ])
    }
}
