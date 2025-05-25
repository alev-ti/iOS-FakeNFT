import Foundation

final class ServicesAssembly {
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let currencyStorage: CurrencyStorageProtocol

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        currencyStorage: CurrencyStorageProtocol
    ) {
        self.networkClient   = networkClient
        self.nftStorage      = nftStorage
        self.currencyStorage = currencyStorage
    }

    lazy var userService: UserServiceProtocol = {
        guard
            let baseURLString = Bundle.main.object(forInfoDictionaryKey: "PracticumBaseURL") as? String,
            let baseURL = URL(string: baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)),
            let token   = Bundle.main.object(forInfoDictionaryKey: "PracticumMobileToken") as? String
        else {
            fatalError("PracticumBaseURL / PracticumMobileToken missing")
        }
        return UserService(baseURL: baseURL, token: token)
    }()

    var nftService: NftService {
        NftServiceImpl(storage: nftStorage, userService: userService)
    }

    var currencyService: CurrencyServiceProtocol {
        CurrencyService(networkClient: networkClient, storage: currencyStorage)
    }
}
