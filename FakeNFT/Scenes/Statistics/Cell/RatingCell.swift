import UIKit

final class RatingCell: UITableViewCell {
    static let reuseIdentifier = "RatingCell"
    
    private let rankLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .secondaryLabel
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 248/255, alpha: 1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 14
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 28),
            iv.heightAnchor.constraint(equalToConstant: 28)
        ])
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()
    
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()
    
    
    private let countLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()
    
    
    private let hStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(rankLabel)
        contentView.addSubview(containerView)
        containerView.addSubview(hStack)
        
        hStack.addArrangedSubview(avatarImageView)
        hStack.addArrangedSubview(nameLabel)
        hStack.addArrangedSubview(countLabel)
        hStack.setCustomSpacing(8, after: avatarImageView)
        
        NSLayoutConstraint.activate([
            
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 24),
            
            
            containerView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            
            hStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            hStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    func configure(with vm: RatingViewModel) {
        rankLabel.text  = "\(vm.rank)"
        nameLabel.text  = vm.name
        countLabel.text = "\(vm.nftCount)"
        
        
        avatarImageView.image = UIImage(named: "userpick")?.withRenderingMode(.alwaysOriginal)
        
        
        if let url = vm.avatarURL {
            URLSession.shared.dataTask(with: url) { data,_,_ in
                guard let d = data, let img = UIImage(data: d) else { return }
                DispatchQueue.main.async {
                    self.avatarImageView.image = img
                }
            }.resume()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rankLabel.text       = nil
        nameLabel.text       = nil
        countLabel.text      = nil
        avatarImageView.image = nil
    }
}
