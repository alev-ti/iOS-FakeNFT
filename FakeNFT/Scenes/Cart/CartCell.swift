import UIKit
import Kingfisher

protocol CartCellDelegate: AnyObject {
    func didTapButton(on cell: CartCell)
}

final class CartCell: UICollectionViewCell {
    
    // MARK: - Properties
    weak var delegate: CartCellDelegate?
    private var nftID: String = ""
    
    private lazy var screenWidth = UIScreen.main.bounds.width
    private lazy var widthScaleFactor = screenWidth / 375
    
    // MARK: - UI Elements
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.backgroundColor = UIColor.red.cgColor
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var nftNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bold17
        label.textColor = .themeFont
        return label
    }()
    
    private lazy var ratingView: RatingView = {
        let view = RatingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var costLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.regular13
        label.textColor = .themeFont
        return label
    }()
    
    private lazy var costCounterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.bold17
        label.textColor = .themeFont
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: CartViewController.Constants.deleteNftIcon)?
            .withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .iconButton
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(nftNameLabel)
        contentView.addSubview(ratingView)
        contentView.addSubview(costLabel)
        contentView.addSubview(costCounterLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // NFT Image
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            nftImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            nftImageView.widthAnchor.constraint(equalTo: nftImageView.heightAnchor),
            
            // Delete Button
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 40 * widthScaleFactor),
            deleteButton.heightAnchor.constraint(equalToConstant: 40 * widthScaleFactor),
            
            // Name Label
            nftNameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            nftNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            nftNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor),
            nftNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -24),
            
            // Rating View
            ratingView.leadingAnchor.constraint(equalTo: nftNameLabel.leadingAnchor, constant: -4),
            ratingView.topAnchor.constraint(equalTo: nftNameLabel.bottomAnchor, constant: 4),
            
            // Cost Counter Label
            costCounterLabel.leadingAnchor.constraint(equalTo: nftNameLabel.leadingAnchor),
            costCounterLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            costCounterLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor),
            costCounterLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 24),
            
            // Cost Label
            costLabel.leadingAnchor.constraint(equalTo: nftNameLabel.leadingAnchor),
            costLabel.bottomAnchor.constraint(equalTo: costCounterLabel.topAnchor, constant: -2),
            costLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor),
            costLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 24)
        ])
    }
    
    // MARK: - Public Methods
    func configure(with nft: Nft, stubImage: UIImage? = UIImage()) {
        if let imageUrl = nft.images.first {
            nftImageView.kf.setImage(with: imageUrl, placeholder: stubImage)
        } else {
            nftImageView.image = stubImage
        }
        
        nftID = nft.id
        nftNameLabel.text = nft.name
        ratingView.rating = nft.rating
        costLabel.text = CartViewController.Constants.costString
        costCounterLabel.text = "\(String(format: "%.2f", nft.price)) ETH"
    }
    
    func getNftID() -> String {
        return nftID
    }
    
    // MARK: - Actions
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        delegate?.didTapButton(on: self)
    }
}
