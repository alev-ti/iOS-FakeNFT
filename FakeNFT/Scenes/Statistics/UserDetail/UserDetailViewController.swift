import UIKit

final class UserDetailViewController: UIViewController, UserDetailViewProtocol {
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 35
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "userpick")
        return iv
    }()

    private lazy var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .black
        lbl.numberOfLines = 1
        return lbl
    }()

    private lazy var descLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textColor = .darkGray
        return lbl
    }()

    private lazy var websiteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Перейти на сайт пользователя", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()

    private lazy var collectionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Коллекция NFT   (0)", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.contentHorizontalAlignment = .left
        
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .black
        arrow.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(arrow)
        NSLayoutConstraint.activate([
            arrow.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -16),
            arrow.widthAnchor.constraint(equalToConstant: 10),
            arrow.heightAnchor.constraint(equalToConstant: 17)
        ])
        
        return btn
    }()

  
    var presenter: UserDetailPresenterProtocol!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupLayout()
        websiteButton.addTarget(self, action: #selector(onWebsite), for: .touchUpInside)
        collectionButton.addTarget(self, action: #selector(onCollection), for: .touchUpInside)
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
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide
        [avatarImageView, nameLabel, descLabel, websiteButton, collectionButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            descLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),

            websiteButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20),
            websiteButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            websiteButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            websiteButton.heightAnchor.constraint(equalToConstant: 40),

            collectionButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 55),
            collectionButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            collectionButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            collectionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    
    @objc private func onBack() { navigationController?.popViewController(animated: true) }
    @objc private func onWebsite() { presenter.didTapWebsite() }
    @objc private func onCollection() { presenter.didTapCollection() }

    
    func showLoading(_ isLoading: Bool) {}

    func showUser(_ model: UserDetailViewModel) {
       
        if let url = model.avatarURL {
            URLSession.shared.dataTask(with: url) { data,_,_ in
                if let d = data, let img = UIImage(data: d) {
                    DispatchQueue.main.async { self.avatarImageView.image = img }
                }
            }.resume()
        }
        nameLabel.text = model.name

        
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 18
        paragraph.maximumLineHeight = 18
        paragraph.alignment = .left

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .kern: -0.08,
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor.darkGray
        ]
        descLabel.attributedText = NSAttributedString(string: model.description, attributes: attrs)

        websiteButton.isHidden = (model.websiteURL == nil)
        if Optional(model.nftCount) != nil {
            let count = model.nftCount
            let titleString = "Коллекция NFT (\(count))"
            let attributed = NSMutableAttributedString(
                string: titleString,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
            )
                        if let range = titleString.range(of: "T") {
                let nsRange = NSRange(range, in: titleString)
                attributed.addAttribute(.kern, value: 8, range: nsRange)
            }
            collectionButton.setAttributedTitle(attributed, for: .normal)
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
}
