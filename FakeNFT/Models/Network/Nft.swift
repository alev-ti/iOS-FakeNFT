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
