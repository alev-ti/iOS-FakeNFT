import Foundation

struct Nft: Codable {
    let createdAt, name: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Double
    let author: String
    let id: String
    
    init(createdAt: String = "", name: String  = "Default", images: [URL] = [], rating: Int = 5, description: String = "", price: Double = 0.00, author: String = "Default", id: String = "Default") {
        self.createdAt = createdAt
        self.name = name
        self.images = images
        self.rating = rating
        self.description = description
        self.price = price
        self.author = author
        self.id = id
    }
}

extension Nft {
    func isOrderedBefore(_ other: Nft, by sortingMethod: SortingMethod) -> Bool {
        switch sortingMethod {
        case .price:
            return price < other.price
        case .name:
            return name.localizedCompare(other.name) == .orderedAscending
        case .rating:
            return rating > other.rating
        }
    }
}
