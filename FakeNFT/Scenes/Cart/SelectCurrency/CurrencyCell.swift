import UIKit

final class CurrencyCell: UICollectionViewCell {
    static let reuseIdentifier = "CurrencyCell"
    
    private let currencyImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let currencyBackgroundView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.backgroundColor = UIColor.black.cgColor
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()

    private let currencyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regular13
        label.textColor = .dynamicBlack
        return label
    }()

    private let currencyTokenLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .regular13
        label.textColor = .yaGreenUniversal
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    func configure(with currency: Currency) {
        currencyImageView.kf.setImage(with: URL(string: currency.image))
        currencyTitleLabel.text = currency.title
        currencyTokenLabel.text = currency.name
    }
    
    func toggleSelectState(_ isSelected: Bool) {
        contentView.layer.borderWidth = isSelected ? 1.0 : 0
    }
    
    private func configureCell() {
        contentView.backgroundColor = .dynamicLightGray
        contentView.layer.borderColor = UIColor.dynamicBlack.cgColor
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    private func setupLayout() {
        [currencyBackgroundView, currencyTitleLabel, currencyTokenLabel].forEach {
            contentView.addSubview($0)
        }
        currencyBackgroundView.addSubview(currencyImageView)
        
        NSLayoutConstraint.activate([
            currencyBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            currencyBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            currencyBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            currencyBackgroundView.widthAnchor.constraint(equalTo: currencyBackgroundView.heightAnchor),
            
            currencyImageView.centerXAnchor.constraint(equalTo: currencyBackgroundView.centerXAnchor),
            currencyImageView.centerYAnchor.constraint(equalTo: currencyBackgroundView.centerYAnchor),
            currencyImageView.widthAnchor.constraint(equalTo: currencyBackgroundView.widthAnchor),
            currencyImageView.heightAnchor.constraint(equalTo: currencyBackgroundView.heightAnchor),
            
            currencyTitleLabel.leadingAnchor.constraint(equalTo: currencyBackgroundView.trailingAnchor, constant: 4),
            currencyTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            currencyTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            currencyTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -7),
            
            currencyTokenLabel.leadingAnchor.constraint(equalTo: currencyTitleLabel.leadingAnchor),
            currencyTokenLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            currencyTokenLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            currencyTokenLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 7)
        ])
    }
}
