// Copyright © 2020 cryptospace. All rights reserved.

import Foundation
import web3
import Web3Swift
import BigInt

class Ethereum {
    
    static let shared = Ethereum()
    
    private let client = EthereumClient(url: URL(string: "https://ropsten.infura.io/v3/3f99b6096fda424bbb26e17866dcddfc")!)
    
    var hasAccount: Bool {
        return Defaults.privateKey != nil
    }
    
    private let network = AlchemyNetwork(chain: "ropsten", apiKey: "RKg5wIwcuh32powb0blKdPh0UwSsgmFI")
    
    private let contractInteractor: ContractInteractor
    
    private let contractAddress = EthAddress(hex: "0xDa48cf4b77cbA177C0234A382d994Ed1d79A9ee4")
    
    private let ens = EthereumNameService(
        client: EthereumClient(url:
            URL(string: "https://ropsten.infura.io/v3/3f99b6096fda424bbb26e17866dcddfc")!
        ),
        registryAddress: EthereumAddress("0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e")
    )
    
    func getENSName(address: String, completion: @escaping (String?) -> Void) {
        ens.resolve(address: EthereumAddress(address)) { error, result in
            if error == nil, let name = result {
                completion(name)
            } else {
                completion(nil)
            }
        }
    }

    init() {
        contractInteractor = Web3ContractInteractor(
            contract: contractAddress,
            network: network
        )
    }
    
    let queue = DispatchQueue(label: "Ethereum", qos: .userInteractive)
    
    func getWinner(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async { [weak self] in
            if let winner = try? self?.getChallengeWinner(id: id) {
                DispatchQueue.main.async { completion(.success(winner)) }
            } else {
                DispatchQueue.main.async { completion(.failure(ContractError.unknownError)) }
            }
        }
    }
    
    enum ContractError: Error {
        case unknownError
    }
    
    func getBid(id: String, completion: @escaping (Result<EthNumber?, Error>) -> Void) {
        queue.async { [weak self] in
            if let bid = try? self?.getChallengeBid(id: id),
                let bidData = try? bid.value() {
                var result: EthNumber?
                if !Ethereum.isEmptyData(bidData) {
                    result = bid
                }
                DispatchQueue.main.async { completion(.success(result)) }
            } else {
                DispatchQueue.main.async { completion(.failure(ContractError.unknownError)) }
            }
        }
    }
    
    func getIsFinished(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        queue.async { [weak self] in
            if let finished = try? self?.gameFinished(id: id) {
                DispatchQueue.main.async { completion(.success(finished)) }
            } else {
                DispatchQueue.main.async { completion(.failure(ContractError.unknownError)) }
            }
        }
    }
    
    func getPlayers(id: String, completion: @escaping (Result<Array<String>, Error>) -> Void) {
        queue.async { [weak self] in
            if let names = try? self?.getChallengeNames(id: id) {
                DispatchQueue.main.async { completion(.success(names)) }
            } else {
                DispatchQueue.main.async { completion(.failure(ContractError.unknownError)) }
            }
        }
    }
    
    func createContractChallenge(id: String, name: String, bid: EthNumber, completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            let signature = "createNewChallange(string,string)"
            let idString = SimpleString(string: id)
            let nameString = SimpleString(string: name.lowercased())
            let functionABI = EncodedABIFunction(signature: signature, parameters: [
                ABIString(origin: idString),
                ABIString(origin: nameString)
            ])
            let privateKey = EthPrivateKey(hex: Defaults.privateKey!)
            if let _ = try? self?.contractInteractor.send(function: functionABI, value: bid, sender: privateKey) {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    func joinContractChallenge(id: String, name: String, bid: EthNumber, completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            let signature = "connectToChallenge(string,string)"
            let idString = SimpleString(string: id)
            let nameString = SimpleString(string: name.lowercased())
            let functionABI = EncodedABIFunction(signature: signature, parameters: [
                ABIString(origin: idString),
                ABIString(origin: nameString)
            ])
            let privateKey = EthPrivateKey(hex: Defaults.privateKey!)
            if let _ = try? self?.contractInteractor.send(function: functionABI, value: bid, sender: privateKey) {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    func sendPrize(id: String, completion: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            let signature = "sendFunds(string)"
            let ethString = SimpleString(string: id)
            let functionABI = EncodedABIFunction(signature: signature, parameters: [
                ABIString(origin: ethString)
            ])
            if let privateKey = Defaults.privateKey,
                let _ = try? self?.contractInteractor.send(function: functionABI, value: EthNumber(value: 0), sender: EthPrivateKey(hex: privateKey)) {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    func getBalance(completion: @escaping (Result<String, Error>) -> Void) {
        guard let key = Defaults.privateKey,
            let addressValue = try? EthPrivateKey(hex: key).address().value().toHexString() else {
            DispatchQueue.main.async { completion(.failure(ContractError.unknownError)) }
            return
        }
        let address = "0x" + addressValue
        client.eth_blockNumber { [weak client] error, block in
            guard let block = block else {
                DispatchQueue.main.async { completion(.failure(ContractError.unknownError)) }
                return
            }
            client?.eth_getBalance(address: address, block: EthereumBlock(rawValue: block)) { error, balance in
                guard let balance = balance, key == Defaults.privateKey else {
                    DispatchQueue.main.async { completion(.failure(ContractError.unknownError)) }
                    return
                }
                
                let balanceString = String(balance, radix: 10)
                let ethString = String((Double(balanceString) ?? 0) / 1e18)
                DispatchQueue.main.async { completion(.success(ethString)) }
            }
        }
    }
    
    private func gameFinished(id: String) throws -> Bool {
        let signature = "didSentFunds(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let abiMessage = try contractInteractor.call(function: functionABI)
        let finished = try ABIDecoder().boolean(message: abiMessage)
        return finished
    }
    
    private func getChallengeWinner(id: String) throws -> String {
        let signature = "getChallengeWinner(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let abiMessage = try contractInteractor.call(function: functionABI)
        let winner = try ABIDecoder().string(message: abiMessage)
        return winner
    }
    
    private func getChallengeBid(id: String) throws -> EthNumber {
        let signature = "getChallengeBid(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let abiMessage = try contractInteractor.call(function: functionABI)
        let bid = try ABIDecoder().number(message: abiMessage)
        return bid
    }
    
    private func getChallengeNames(id: String) throws -> [String] {
        let signature = "getChallengeNames(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let abiMessage = try contractInteractor.call(function: functionABI)
        let decodedMessage = DecodedABIDynamicCollection<String>(
            abiMessage: abiMessage,
            mapping: { slice, index in
                let message = ConcatenatedBytes(bytes: try slice.value())
                return try ABIDecoder().string(
                    message: ABIMessage(message: message),
                    index: index
                )
        }, index: 0)
        let names = try decodedMessage.value()
        return names
    }
    
    static private func isEmptyData(_ data: Data) -> Bool {
        let hex = data.toHexString()
        if data.isEmpty || hex == "0" || hex == "00" {
            return true
        } else {
            return false
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

extension EthNumber {
    
    private func toDouble() -> Double {
        guard
            let bidHex = try? self.value().toHexString(),
            let bidInt = UInt64(bidHex, radix: 16) else { return 0 }
        let bid = Double(bidInt) / 1e18
        return bid
    }
    
    func prizeFor(_ users: Int) -> String {
        return String(toDouble() * Double(users)) + " ETH"
    }
    
    var ethString: String {
        return String(toDouble()) + " ETH"
    }
    
}
