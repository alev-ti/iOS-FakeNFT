import UIKit

final class UserDetailViewController: UIViewController {
    
    private let model: RatingViewModel
    
    
    private let nameLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let countLabel = UILabel()
    
    init(model: RatingViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Пользователь"
        setupLayout()
        configure()
    }
    
    private func setupLayout() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        
        nameLabel.font = .preferredFont(forTextStyle: .title2)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.font = .preferredFont(forTextStyle: .body)
        countLabel.textColor = .secondaryLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            countLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func configure() {
        nameLabel.text = model.name
        countLabel.text = "NFT: \(model.nftCount)"
        if let url = model.avatarURL {
            URLSession.shared.dataTask(with: url) { data,_,_ in
                guard let d = data, let img = UIImage(data: d) else { return }
                DispatchQueue.main.async { self.avatarImageView.image = img }
            }.resume()
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle")
        }
    }
}
