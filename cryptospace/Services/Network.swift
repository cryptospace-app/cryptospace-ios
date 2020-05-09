// Copyright © 2020 cryptospace. All rights reserved.

import Foundation

class Network {
    
    static let shared = Network()
    private init() {}
    
    struct NetworkError: Error {}
    
    private let session: URLSession = {
        let newSession = URLSession(configuration: URLSessionConfiguration.default)
        return newSession
    }()
    
//    func getChallenge(id: String, completion: @escaping (Result<Challenge, Error>) -> Void) {
//        let url = URL(string: "")
//        let task = session.dataTask(with: url) { data, _, _ in
//            guard let data = data, let challenge = try? JSONDecoder().decode(Challenge.self, from: data) else {
//                DispatchQueue.main.async { completion(.failure(NetworkError())) }
//                return
//            }
//            DispatchQueue.main.async {
//                completion(.success(challenge))
//            }
//        }
//        task.resume()
//    }
    
}
