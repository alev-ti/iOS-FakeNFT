import Foundation

protocol CartPresenter {
    func getNFTs() -> [Nft]?
    func viewDidLoad()
    func filterButtonTapped()
    func paymentButtonTapped()
    func deleteNFT(with id: String)
}

final class CartPresenterImpl: CartPresenter {
    
    // MARK: - Properties
    
    weak var view: CartView?
    private let nftService: NftService
    
    private let testNFTs: [String] = [
        "b2f44171-7dcd-46d7-a6d3-e2109aacf520",
        "1464520d-1659-4055-8a79-4593b9569e48",
        "fa03574c-9067-45ad-9379-e3ed2d70df78"
    ]
    
    private let testNFTsInCart: [String] = [
        "b2f44171-7dcd-46d7-a6d3-e2109aacf520",
        "1464520d-1659-4055-8a79-4593b9569e48",
        "fa03574c-9067-45ad-9379-e3ed2d70df78"
    ]
    
    private var nfts: [Nft] = [] {
        didSet {
            view?.toggleEmptyCartView(show: nfts.isEmpty)
            view?.configurePrice(with: getTotal(), nftsCount: nfts.count)
        }
    }
    
    // MARK: - Initialization
    
    init(nftService: NftService) {
        self.nftService = nftService
        setupObservers()
        addNFTsToCart(nftIDs: testNFTsInCart)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        view?.showLoading()
        loadNfts(byIDs: testNFTs) { [weak self] in
            self?.updateNFTs()
            self?.view?.toggleEmptyCartView(show: self?.nfts.isEmpty ?? true)
            self?.view?.updateCollectionView()
            self?.view?.configurePrice(
                with: self?.getTotal() ?? 0,
                nftsCount: self?.nfts.count ?? 0
            )
            self?.view?.hideLoading()
        }
    }
    
    func deleteNFT(with id: String) {
        CartStore.cartItemIDs.remove(id)
    }
    
    func getNFTs() -> [Nft]? {
        return nfts
    }
    
    func filterButtonTapped() {
        print("CartPresenter: filter button tapped")
    }
    
    func paymentButtonTapped() {
        print("CartPresenter: payment button tapped")
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
        updateNFTs()
    }
    
    private func updateNFTs() {
        guard let nfts = getNFTsInCartByID(nftsInCart: Array(CartStore.cartItemIDs)) else { return }
        self.nfts = nfts
    }
    
    private func getNFTsInCartByID(nftsInCart: [String]) -> [Nft]? {
        var nfts: [Nft] = []
        for id in nftsInCart {
            if let nft = nftService.getNftFromStorage(by: id) {
                nfts.append(nft)
            }
        }
        return nfts
    }
    
    private func loadNfts(byIDs ids: [String], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        ids.forEach { id in
            dispatchGroup.enter()
            nftService.loadNft(id: id) { result in
                defer { dispatchGroup.leave() }
                
                switch result {
                case .success(let nft):
                    print("Loaded NFT: \(nft)")
                case .failure(let error):
                    print("Failed to load NFT: \(error.localizedDescription)")
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func getTotal() -> Double {
        return nfts.reduce(0) { $0 + $1.price }
    }
    
    private func addNFTsToCart(nftIDs: [String]) {
        CartStore.cartItemIDs.formUnion(nftIDs)
    }
}
