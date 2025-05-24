import UIKit

final class UserCollectionCell: UICollectionViewCell {
    static let reuseID = "UserCollectionCell"

    private let imageView = UIImageView()
    private let heartIcon = UIImageView()
    private let starsStack = UIStackView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let cartButton = UIButton(type: .system)

    
    var onCartToggle: (() -> Void)?
    var onLikeToggle: (() -> Void)?

    private var isLiked: Bool = false {
        didSet {
            let imageName = isLiked ? "like_icon_active" : "like_icon"
            heartIcon.image = UIImage(named: imageName)
        }
    }

    private var isInCart: Bool = false {
        didSet {
            
            cartButton.setImage(UIImage(named: "bag"), for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)

        
        heartIcon.translatesAutoresizingMaskIntoConstraints = false
        heartIcon.contentMode = .scaleAspectFit
        heartIcon.isUserInteractionEnabled = true
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(toggleLike))
        heartIcon.addGestureRecognizer(likeTap)
        contentView.addSubview(heartIcon)

        
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        starsStack.axis = .horizontal
        starsStack.spacing = 4
        for _ in 0..<5 {
            let star = UIImageView()
            star.translatesAutoresizingMaskIntoConstraints = false
            star.widthAnchor.constraint(equalToConstant: 12).isActive = true
            star.heightAnchor.constraint(equalToConstant: 12).isActive = true
            starsStack.addArrangedSubview(star)
        }
        contentView.addSubview(starsStack)

        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1
        contentView.addSubview(nameLabel)

        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        priceLabel.textColor = .darkGray
        contentView.addSubview(priceLabel)

    
        cartButton.translatesAutoresizingMaskIntoConstraints = false
        cartButton.tintColor = .black
        cartButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        cartButton.heightAnchor.constraint(equalToConstant: 19).isActive = true
        cartButton.addTarget(self, action: #selector(toggleCart), for: .touchUpInside)
        contentView.addSubview(cartButton)

        
        NSLayoutConstraint.activate([
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 108),
            imageView.heightAnchor.constraint(equalToConstant: 108),

            
            heartIcon.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            heartIcon.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            heartIcon.widthAnchor.constraint(equalToConstant: 18),
            heartIcon.heightAnchor.constraint(equalToConstant: 16),

            
            starsStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            starsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            
            nameLabel.topAnchor.constraint(equalTo: starsStack.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: cartButton.leadingAnchor, constant: -8),

            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

            
            cartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with vm: NftViewModel) {
        nameLabel.text = vm.name
        priceLabel.text = String(format: "%.2f ETH", vm.price)

        
        for (i, view) in starsStack.arrangedSubviews.enumerated() {
            guard let starView = view as? UIImageView else { continue }
            let imageName = i < vm.rating ? "rating_star_active" : "rating_star_inactive"
            starView.image = UIImage(named: imageName)
        }

        
        imageView.image = nil
        if let url = vm.imageURL {
            URLSession.shared.dataTask(with: url) { data,_,_ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self.imageView.image = img }
            }.resume()
        }

        
        isInCart = vm.isInCart

        
        isLiked = vm.isLiked
    }

    @objc private func toggleCart() {
        onCartToggle?()
    }

    @objc private func toggleLike() {
        onLikeToggle?()
    }
}
