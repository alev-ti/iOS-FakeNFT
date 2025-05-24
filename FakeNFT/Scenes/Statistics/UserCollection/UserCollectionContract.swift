import Foundation
import UIKit


protocol UserCollectionPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didToggleCart(nftId: String)
    func didToggleLike(nftId: String)
}


protocol UserCollectionViewProtocol: AnyObject {
    func showLoading(_ isLoading: Bool)
    func showNfts(_ items: [NftViewModel])
    func showError(_ message: String)
}


struct NftViewModel {
    let id: String
    let name: String
    let imageURL: URL?
    let rating: Int
    let price: Double
    let isInCart: Bool
    let isLiked: Bool
}
