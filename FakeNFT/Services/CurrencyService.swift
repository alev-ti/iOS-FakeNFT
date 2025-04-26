import Foundation

typealias CurrenciesCompletion = (Result<[Currency], Error>) -> Void
typealias SetCurrencyIDCompletion = (Result<SetCurrencyIDResponse, Error>) -> Void
typealias PaymentCompletion = (Result<PutOrderAndPayResponse, Error>) -> Void

protocol CurrencyServiceProtocol {
    func requestCurrencies(completion: @escaping CurrenciesCompletion)
    func setCurrencyIDBeforePayment(_ currencyID: String, completion: @escaping SetCurrencyIDCompletion)
    func putOrderAndPayRequest(nfts: [String], completion: @escaping PaymentCompletion)
}

final class CurrencyService {
    private let networkClient: NetworkClient
    private let storage: CurrencyStorageProtocol
    
    init(networkClient: NetworkClient, storage: CurrencyStorageProtocol) {
        self.networkClient = networkClient
        self.storage = storage
    }
}

extension CurrencyService: CurrencyServiceProtocol {
    func requestCurrencies(completion: @escaping CurrenciesCompletion) {
        if let storedCurrencies = storage.getCurrencies() {
            return completion(.success(storedCurrencies))
        }
        
        let request = CurrenciesRequest()
        
        networkClient.send(request: request, type: [Currency].self) { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.storage.saveCurrencies(currencies)
                completion(.success(currencies))
            case .failure(let error):
                print("Failed to load currencies:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func setCurrencyIDBeforePayment(_ currencyID: String, completion: @escaping SetCurrencyIDCompletion) {
        let request = PaymentRequest(id: currencyID)
        
        networkClient.send(request: request, type: SetCurrencyIDResponse.self) { result in
            completion(result)
        }
    }
    
    func putOrderAndPayRequest(nfts: [String], completion: @escaping PaymentCompletion) {
        let dto = PutOrderAndPayDtoObject(nfts: nfts)
        let request = PutOrderAndPayRequest(dto: dto)
        
        networkClient.send(request: request, type: PutOrderAndPayResponse.self) { result in
            switch result {
            case .success(let response):
                print("Payment successful for NFTs:", response.nfts.joined(separator: ", "))
                completion(.success(response))
            case .failure(let error):
                print("Payment failed:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
}
