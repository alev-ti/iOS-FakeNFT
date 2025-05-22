import Foundation


struct User: Decodable {
    
    let id: String
    let name: String
    let avatar: String?
    let nfts: [String]
}


protocol UserServiceProtocol {
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void)
}


final class UserService: UserServiceProtocol {
    private let baseURL: URL
    private let token: String

    init(baseURL: URL, token: String) {
        self.baseURL = baseURL
        self.token   = token
    }

    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        
        let url = baseURL.appendingPathComponent("users")
        print("📡 Will request:", url.absoluteString)
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error)); return
            }
            if let http = response as? HTTPURLResponse {
                print("🛂 HTTP Status:", http.statusCode)
            }
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "UserService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Пустой ответ"]
                )))
                return
            }
            if let raw = String(data: data, encoding: .utf8) {
                print("🔍 Raw /users response:\n\(raw)")
            }
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                print("✅ Decoded users count:", users.count)
                completion(.success(users))
            } catch {
                print("❌ JSON decode error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
}

