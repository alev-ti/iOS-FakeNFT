final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let currencyStorage: CurrencyStorageProtocol

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        currencyStorage: CurrencyStorageProtocol
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.currencyStorage = currencyStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    var currencyService: CurrencyServiceProtocol {
        CurrencyService(
            networkClient: networkClient,
            storage: currencyStorage
        )
    }
}
