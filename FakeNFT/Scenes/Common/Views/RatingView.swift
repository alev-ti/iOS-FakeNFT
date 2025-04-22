import UIKit

public final class RatingView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let maxStarsCount = 5
        static let starSpacing: CGFloat = 4
        static let activeStarImageName = "rating_star_active"
        static let inactiveStarImageName = "rating_star_inactive"
    }
    
    // MARK: - Properties
    private var starImageViews: [UIImageView] = []
    
    public var rating: Int = 0 {
        didSet {
            updateStarsAppearance()
        }
    }
    
    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    // MARK: - Private Methods
    private func configureView() {
        createStarViews()
        setupConstraints()
    }
    
    private func createStarViews() {
        starImageViews = (0..<Constants.maxStarsCount).map { _ in
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: Constants.inactiveStarImageName)
            addSubview(imageView)
            return imageView
        }
    }
    
    private func setupConstraints() {
        starImageViews.enumerated().forEach { index, starView in
            // Leading constraint
            let leadingAnchor = index == 0 ? leadingAnchor : starImageViews[index - 1].trailingAnchor
            starView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.starSpacing
            ).isActive = true
            
            // Common constraints
            NSLayoutConstraint.activate([
                starView.topAnchor.constraint(equalTo: topAnchor),
                starView.bottomAnchor.constraint(equalTo: bottomAnchor),
                starView.widthAnchor.constraint(equalTo: starView.heightAnchor)
            ])
        }
        
        starImageViews.last?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func updateStarsAppearance() {
        starImageViews.enumerated().forEach { index, starView in
            starView.image = UIImage(
                named: index < rating ? Constants.activeStarImageName : Constants.inactiveStarImageName
            )
        }
    }
}
