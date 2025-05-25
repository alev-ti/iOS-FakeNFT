import Foundation

final class UserCollectionPresenter: UserCollectionPresenterProtocol {
    private weak var view: UserCollectionViewProtocol?
    private let service: NftService
    private let ownerId: String

    private var likedIds: Set<String> = []

    init(view: UserCollectionViewProtocol,
         service: NftService,
         ownerId: String) {
        self.view    = view
        self.service = service
        self.ownerId = ownerId
    }

    func viewDidLoad() {
        view?.showLoading(true)
        service.loadNfts(ownerId: ownerId) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.showLoading(false)
                switch result {
                case .success(let nfts):
                    let vms = nfts.map { nft in
                        NftViewModel(
                            id:       nft.id,
                            name:     nft.name,
                            imageURL: nft.images.first,
                            rating:   nft.rating,
                            price:    nft.price,
                            isInCart: CartStore.cartItemIDs.contains(nft.id),
                            isLiked:  self?.likedIds.contains(nft.id) ?? false
                        )
                    }
                    self?.view?.showNfts(vms)
                case .failure(let err):
                    self?.view?.showError(err.localizedDescription)
                }
            }
        }
    }

    func didToggleCart(nftId: String) {
        
        var set = CartStore.cartItemIDs
        if set.contains(nftId) { set.remove(nftId) }
        else                   { set.insert(nftId) }
        CartStore.cartItemIDs = set
        viewDidLoad()
    }

    func didToggleLike(nftId: String) {
       
        view?.showLoading(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            if self.likedIds.contains(nftId) {
                self.likedIds.remove(nftId)
            } else {
                self.likedIds.insert(nftId)
            }
            self.viewDidLoad()
        }
    }
}
