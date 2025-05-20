import Foundation

struct NftsByOwnerRequest: NetworkRequest {
    let ownerId: String
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nfts?ownerId=\(ownerId)")
    }
    var dto: Dto? { nil }
}
