import Foundation

typealias NftCompletion  = (Result<Nft, Error>) -> Void
typealias NftsCompletion = (Result<[Nft], Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func getNftFromStorage(by id: String) -> Nft?
    func loadNfts(ownerId: String, completion: @escaping NftsCompletion)
}

final class NftServiceImpl: NftService {
    private let storage: NftStorage
    private let userService: UserServiceProtocol
    private let baseURLString: String
    private let token: String

    init(storage: NftStorage, userService: UserServiceProtocol) {
        self.storage     = storage
        self.userService = userService

        guard
          let b = Bundle.main.object(forInfoDictionaryKey: "PracticumBaseURL") as? String,
          let _ = URL(string: b.trimmingCharacters(in: .whitespacesAndNewlines)),
          let t = Bundle.main.object(forInfoDictionaryKey: "PracticumMobileToken") as? String
        else {
          fatalError("PracticumBaseURL или PracticumMobileToken не найдены в Info.plist")
        }
        self.baseURLString = b.trimmingCharacters(in: .whitespacesAndNewlines)
        self.token         = t
    }

    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            return completion(.success(nft))
        }
        
        let urlString = "\(baseURLString)/nft/\(id)"
        guard let url = URL(string: urlString) else {
            print("❌ [NftService] invalid URL:", urlString)
            return completion(.failure(NSError()))
        }
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        print("➡️ [NftService] loadNft URL:", urlString)

        URLSession.shared.dataTask(with: request) { data, resp, err in
            if let err = err {
                print("❌ [NftService] network error for id \(id):", err)
                return completion(.failure(err))
            }
            if let http = resp as? HTTPURLResponse {
                print("⬅️ [NftService] HTTP \(http.statusCode) for id:", id)
            }
            guard let d = data else {
                print("❌ [NftService] no data for id:", id)
                return completion(.failure(NSError(domain:"NftService", code:0)))
            }
            if let json = String(data: d, encoding: .utf8) {
                print("📦 [NftService] raw JSON for id \(id):", json)
            }
            do {
                let nft = try JSONDecoder().decode(Nft.self, from: d)
                print("✅ [NftService] decoded NFT for id:", id)
                self.storage.saveNft(nft)
                completion(.success(nft))
            } catch {
                print("❌ [NftService] decode error for id \(id):", error)
                completion(.failure(error))
            }
        }.resume()
    }

    func getNftFromStorage(by id: String) -> Nft? {
        storage.getNft(with: id)
    }

    func loadNfts(ownerId: String, completion: @escaping NftsCompletion) {
        print("🧐 [NftService] loadNfts for ownerId:", ownerId)
        userService.fetchUser(id: ownerId) { [weak self] result in
            switch result {
            case .failure(let err):
                print("❌ [NftService] fetchUser error for ownerId \(ownerId):", err)
                DispatchQueue.main.async { completion(.failure(err)) }

            case .success(let dto):
                print("📋 [NftService] DTO.nfts for ownerId \(ownerId):", dto.nfts)
                let ids = dto.nfts
                var collected: [Nft] = []
                let group = DispatchGroup()

                for id in ids {
                    group.enter()
                    self?.loadNft(id: id) { nftRes in
                        if case .success(let nft) = nftRes {
                            collected.append(nft)
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    print("✅ [NftService] collected NFT count:", collected.count)
                    completion(.success(collected))
                }
            }
        }
    }
}
