import Foundation

struct PutOrderAndPayRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?
}

struct PutOrderAndPayDtoObject: Dto {
   let nfts: [String]

   enum CodingKeys: String, CodingKey {
       case nfts
   }

   func asDictionary() -> [String: String] {
       return [
        CodingKeys.nfts.rawValue: nfts.joined(separator: ",")
       ]
   }
}
