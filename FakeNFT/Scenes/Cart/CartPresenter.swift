import Foundation

protocol CartPresenterProtocol {
    func getNFTs() -> [Nft]?
    func viewDidLoad()
    func filterButtonTapped()
    func paymentButtonTapped()
    func removeButtonTapped(at indexPath: IndexPath)
}

final class CartPresenter: CartPresenterProtocol, SortingDelegate {
    
    // MARK: - Properties
    
    weak var view: CartView?
    var serviceAssembly: ServicesAssembly
    private let nftService: NftService
    
    private var nfts: [Nft] = [] {
        didSet {
            guard let view else { return }
            view.toggleEmptyCartView(show: nfts.isEmpty)
            view.configurePrice(with: getTotal(), nftsCount: nfts.count)
            
        }
    }
    
    // MARK: - Initialization
    
    init(nftService: NftService, serviceAssembly: ServicesAssembly) {
        self.serviceAssembly = serviceAssembly
        self.nftService = nftService
        
        NotificationCenter.default.addObserver(self, selector: #selector(cartDidChange), name: CartStore.cartChangedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        updateCart()
    }
    
    private func getNFTsInCartByID(nftsInCart: [String], completion: @escaping ([Nft]) -> Void) {
        var nfts: [Nft] = []
        let dispatchGroup = DispatchGroup()
        
        for id in nftsInCart {
            dispatchGroup.enter()
            
            nftService.loadNft(id: id) { [weak self] result in
                switch result {
                case .success(let nft):
                    nfts.append(nft)
                case .failure:
                    guard let self, let view = self.view else { return }
                    
                    let action = AlertModel.Action(title: "Попробовать снова", style: .default) {
                        self.updateNFTs() { [weak self] in
                            guard let self else { return }
                            view.toggleEmptyCartView(show: nfts.isEmpty)
                            view.updateCollectionView()
                            view.configurePrice(with: getTotal(), nftsCount: self.nfts.count)
                        }
                    }
                    
                    let alert = AlertModel(title: "Не удалось загрузить NFT", message: "", actions: [action])
                    view.showAlert(alert)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nfts)
        }
    }
    
    private func updateCart() {
        self.updateNFTs() { [weak self] in
            guard let self, let view else { return }
            self.loadNftLargeImage()
            view.toggleEmptyCartView(show: nfts.isEmpty)
            view.updateCollectionView()
            view.configurePrice(with: getTotal(), nftsCount: self.nfts.count)
            view.hideLoading()
        }
    }
    
    private func loadNftLargeImage() {
        guard let imageUrlLight = nfts[safe: 0]?.images[safe: 2],
              let imageUrlDark = nfts[safe: 0]?.images[safe: 1] else { return }
        
        let imageURL = view?.traitCollection.userInterfaceStyle == .dark ? imageUrlDark : imageUrlLight
        
        CartStore.NFTLargeImageURL = imageURL
    }
    
    func removeButtonTapped(at indexPath: IndexPath) {
        guard let view else { return }
        
        let removeFromCartAssembly = RemoveFromCartAssembly()
        guard let removeFromCartVC = removeFromCartAssembly.assemble() as? RemoveFromCartViewProtocol else { return }
        removeFromCartVC.modalPresentationStyle = .overFullScreen
        removeFromCartVC.modalTransitionStyle = .crossDissolve
        
        removeFromCartVC.configureScreen(with: self.nfts[indexPath.row])

        removeFromCartVC.onConfirm = { [weak self] in
            guard let self else { return }
            
            let nftID = self.nfts[indexPath.row].id
            
            removeFromNFTs(at: indexPath.row)
            
            view.performBatchUpdate(deletionAt: indexPath) { [weak self] in
                guard let self else { return }
                self.deleteNftFromCart(with: nftID)
            }
        }
        
        view.present(removeFromCartVC, animated: true, completion: nil)
    }
    
    func getNFTs() -> [Nft]? {
        return nfts
    }
    
    func filterButtonTapped() {
         view?.showAlert(SortingManager.makeSortingAlert(for: self))
     }
    
    func didSelectSortingMethod(_ method: SortingMethod) {
        let originalData = nfts
        nfts.sort { $0.isOrderedBefore($1, by: method) }
        
        var fromIndexPaths = [IndexPath]()
        var toIndexPaths = [IndexPath]()
        
        for (newIndex, nft) in nfts.enumerated() {
            if let oldIndex = originalData.firstIndex(where: { $0.id == nft.id }), oldIndex != newIndex {
                fromIndexPaths.append(IndexPath(item: oldIndex, section: 0))
                toIndexPaths.append(IndexPath(item: newIndex, section: 0))
            }
        }
        
        if fromIndexPaths != toIndexPaths {
            view?.performBatchUpdate(moveFrom: fromIndexPaths, to: toIndexPaths) {}
        }
    }
    
    func paymentButtonTapped() {
        let payAssembly = SelectCurrencyAssembly(servicesAssembly: serviceAssembly)
        guard let payViewController = payAssembly.assemble() as? SelectCurrencyViewProtocol else { return }
        payViewController.hidesBottomBarWhenPushed = true

        guard let view else { return }
        view.setupNavigationBarForNextScreen()
        view.navigationController?.pushViewController(payViewController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidChange),
            name: CartStore.cartChangedNotification,
            object: nil
        )
    }
    
    @objc private func cartDidChange() {
        updateCart()
    }
    
    private func updateNFTs(completion: @escaping ()-> Void) {
        getNFTsInCartByID(nftsInCart: Array(CartStore.cartItemIDs),completion: { nfts in
            self.nfts = nfts
            completion()
        } )
    }
    
    private func removeFromNFTs(at index: Int) {
        nfts.remove(at: index)
    }
    
    private func deleteNftFromCart(with id: String) {
        CartStore.cartItemIDs.remove(id)
    }
    
    private func getTotal() -> Double {
        return nfts.reduce(0) { $0 + $1.price }
    }
}
