// Copyright © 2020 cryptospace. All rights reserved.

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    private init() {}
    
    struct NetworkError: Error {}
    
    private let session: URLSession = {
        let newSession = URLSession(configuration: URLSessionConfiguration.default)
        return newSession
    }()
    
    func getChallenge(id: String, completion: @escaping (Result<Challenge, Error>) -> Void) {
        let url = URL(string: "https://kahoot.it/rest/challenges/\(id)/progress/")!
        let task = session.dataTask(with: url) { data, _, _ in
            guard let data = data, let challenge = try? JSONDecoder().decode(Challenge.self, from: data) else {
                DispatchQueue.main.async { completion(.failure(NetworkError())) }
                return
            }
            DispatchQueue.main.async {
                completion(.success(challenge))
            }
        }
        task.resume()
    }
    
}

struct Challenge: Codable {
    let kahootTitle: String
    let leaderboard: Leaderboard // TODO: убедиться, что ок парсится, когда еще никто не играл
}

struct Leaderboard: Codable {
    let players: [KahootPlayer]
}

struct KahootPlayer: Codable {
    let playerId: String
    let finalScore: Int
    let gamesPlayed: Int // TODO: make sure == 1
}
