import Foundation
import Kingfisher

protocol SuccessPurchasePresenterProtocol {
    func loadNftImage()
    func onDoneButtonTapped()
}

final class SuccessPurchasePresenter: SuccessPurchasePresenterProtocol {
    weak var view: SuccessPurchaseViewProtocol?
    private let imageCache = ImageCache.default
    
    func loadNftImage() {
        guard let imageURL = CartStore.NFTLargeImageURL else { return }
        
        imageCache.retrieveImage(forKey: imageURL.absoluteString) { [weak self] result in
            switch result {
            case .success(let cacheResult):
                self?.handleCacheResult(cacheResult, url: imageURL)
            case .failure(let error):
                print("Image loading error: \(error)")
            }
        }
    }
    
    func onDoneButtonTapped() {
        view?.navigationController?.popToRootViewController(animated: true)
    }
    
    private func handleCacheResult(_ result: ImageCacheResult, url: URL) {
        if let cachedImage = result.image {
            view?.updateNftImage(cachedImage)
        } else {
            view?.loadNftImage(url)
        }
    }
}
