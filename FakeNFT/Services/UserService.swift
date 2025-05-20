import Foundation

struct UserDTO: Decodable {
    let id: String
    let name: String
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]
}

protocol UserServiceProtocol {
    /// Список всех пользователей
    func fetchUsers(completion: @escaping (Result<[UserDTO], Error>) -> Void)
    /// Детали одного пользователя по ID
    func fetchUser(id: String, completion: @escaping (Result<UserDTO, Error>) -> Void)
}

final class UserService: UserServiceProtocol {
    private let baseURL: URL
    private let token: String

    init(baseURL: URL, token: String) {
        self.baseURL = baseURL
        self.token   = token
    }

    func fetchUsers(completion: @escaping (Result<[UserDTO], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("users")
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let err = NSError(
                    domain: "UserService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Empty response"]
                )
                completion(.failure(err))
                return
            }
            do {
                let users = try JSONDecoder().decode([UserDTO].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }

    func fetchUser(id: String, completion: @escaping (Result<UserDTO, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("users/\(id)")
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let err = NSError(
                    domain: "UserService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Empty response"]
                )
                completion(.failure(err))
                return
            }
            do {
                let user = try JSONDecoder().decode(UserDTO.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
}
