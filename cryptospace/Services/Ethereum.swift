// Copyright © 2020 cryptospace. All rights reserved.

import Foundation
import web3
import Web3Swift
import BigInt

class Ethereum {
    
    static let shared = Ethereum()
    private init() {}
    
    private let client = EthereumClient(url: URL(string: "https://ropsten.infura.io/v3/3f99b6096fda424bbb26e17866dcddfc")!)
    
    var hasAccount: Bool {
        return Defaults.privateKey != nil
    }
    
    func getContractChallenge(id: String, completion: @escaping (Result<ContractChallenge?, Error>) -> Void) {
        // TODO: get value from contract
        completion(.success(nil)) // this means that request was successful, but there is no challenge on contract yet
    }
    
    func createContractChallenge(id: String, name: String, bidSize: Double, completion: @escaping (Bool) -> Void) {
        // TODO: talk to contract
        completion(true) // this means challenge was created successfully
    }
    
    func joinContractChallenge(_ challenge: ContractChallenge, name: String, completion: @escaping (Bool) -> Void) {
        // TODO: talk to contract
        completion(true) // this means challenge was joined successfully
    }
    
    func sendPrize(id: String, completion: @escaping (Bool) -> Void) {
        // TODO: talk to contract
        completion(true) // this means that prize was sent
    }
    
    func getBalance(completion: @escaping (Result<String, Error>) -> Void) {
        // TODO: process errors
        guard let key = Defaults.privateKey else { return }
        let address = String(bytes: try! EthPrivateKey(hex: key).address().value().bytes)
        client.eth_blockNumber { [weak client] error, block in
            guard let block = block else { return }
            client?.eth_getBalance(address: address, block: EthereumBlock(rawValue: block)) { error, balance in
                guard let balance = balance, key == Defaults.privateKey else { return }
                DispatchQueue.main.async {
                    var balanceString = String(balance, radix: 10)
                    if balanceString != "0" {
                        while balanceString.hasSuffix("0") {
                            balanceString.removeLast(1)
                        }
                        balanceString = "0.\(balanceString) ETH"
                    }
                    completion(.success(balanceString))
                }
            }
        }
    }

}

struct ContractChallenge {
    let id: String
    let bidSize: Double
    let playerNames: [String]
    let winner: String?
    let isFinished: Bool
}
