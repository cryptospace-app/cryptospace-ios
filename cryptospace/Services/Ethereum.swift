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
    
    private let contractAddress = EthAddress(hex: "0x3fdd9353c4b56b9c0ee72083043b3e150f182855")
    
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
    
    // TODO: вызывать completion-ы на мейн треде
    
    func getWinner(id: String, completion: @escaping (Result<String?, Error>) -> Void) {
        // если nil, значит еще нет на контракте
        // если пустая строка, значит оракул ответил пустой строкой
    }
    
    func getBid(id: String, completion: @escaping (Result<EthNumber?, Error>) -> Void) {
        
    }
    
    func getIsFinished(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
    }
    
    func getPlayers(id: String, completion: @escaping (Result<Array<String>, Error>) -> Void) {
        
    }
    
    func getPlayersAndBid(id: String, completion: @escaping (Result<(players: Array<String>, bid: EthNumber?), Error>) -> Void) {
        // если bid == nil, значит челенж еще не завели
    }
    
    private func getChallengeWinner(id: String) -> String? {
        let signature = "getChallengeWinner(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        if let abiMessage = try? contractInteractor.call(function: functionABI) {
            let winner = try? ABIDecoder().string(message: abiMessage)
            if winner?.isEmpty == true {
                return nil
            } else {
                return winner
            }
        } else {
            return nil
        }
    }
    
    private func getChallengeBid(id: String) -> EthNumber {
        let signature = "getChallengeBid(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let abiMessage = try! contractInteractor.call(function: functionABI)
        let bid = try! ABIDecoder().number(message: abiMessage)
        return bid
    }
    
    private func getChallengeNames(id: String) -> [String] {
        let signature = "getChallengeNames(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let abiMessage = try! contractInteractor.call(function: functionABI)
        let decodedMessage = DecodedABIDynamicCollection<String>(
            abiMessage: abiMessage,
            mapping: { slice, index in
                let message = ConcatenatedBytes(bytes: try slice.value())
                return try ABIDecoder().string(
                    message: ABIMessage(message: message),
                    index: index
                )
        }, index: 0)
        let names = try! decodedMessage.value()
        return names
    }
    
    func getContractChallenge(id: String, completion: @escaping (Result<ContractChallenge?, Error>) -> Void) {
        DispatchQueue.main.async {
            // TODO: dispatch
            let bidData = self.getChallengeBid(id: id)
            let bidHex = try! bidData.value().toHexString()
            let bidInt = UInt64(bidHex, radix: 16)!
            let bid = Double(bidInt) / 1e18;
            
            let names = self.getChallengeNames(id: id)
            let winner = self.getChallengeWinner(id: id)
            let result = ContractChallenge(id: id, bidSize: bid, playerNames: names, winner: winner, isFinished: winner != nil)
            
            completion(.success(result))
        }
    }
    
    func createContractChallenge(id: String, name: String, bidSize: Double, completion: @escaping (Bool) -> Void) {
        let bidStr = String(UInt64(bidSize * 1e18))
        let bid = EthNumber(decimal: bidStr)
        
        let signature = "createNewChallange(string,string)"
        let idString = SimpleString(string: id)
        let nameString = SimpleString(string: name.lowercased())
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: idString),
            ABIString(origin: nameString)
        ])
        let privateKey = EthPrivateKey(hex: Defaults.privateKey!)
        _ = try! contractInteractor.send(function: functionABI, value: bid, sender: privateKey)

        // TODO: talk to contract
        completion(true) // this means challenge was created successfully
    }
    
    func joinContractChallenge(id: String, name: String, bidSize: Double, completion: @escaping (Bool) -> Void) {
        // TODO: talk to contract
//        completion(true) // this means challenge was joined successfully
        let bidStr = String(UInt64(bidSize * 1e18))
        let bid = EthNumber(decimal: bidStr)

        let signature = "connectToChallenge(string,string)"
        let idString = SimpleString(string: id)
        let nameString = SimpleString(string: name.lowercased())
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: idString),
            ABIString(origin: nameString)
        ])
        let privateKey = EthPrivateKey(hex: Defaults.privateKey!)
        _ = try! contractInteractor.send(function: functionABI, value: bid, sender: privateKey)
        completion(true)
    }
    
    private func sendFunds(id: String) -> Bool {
        let signature = "sendFunds(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let privateKey = EthPrivateKey(hex: Defaults.privateKey!)
        _ = try! contractInteractor.send(function: functionABI, value: EthNumber(value: 0), sender: privateKey)
        return true
    }
    
    func sendPrize(id: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            _ = self.sendFunds(id: id)
            completion(true)
        }
    }
    
    func gameFinished(id: String, completion: @escaping (Bool) -> Void) {
        let signature = "didSentFunds(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        let abiMessage = try! contractInteractor.call(function: functionABI)
        let finished = try! ABIDecoder().boolean(message: abiMessage)
        completion(finished)
    }
    
    func getBalance(completion: @escaping (Result<String, Error>) -> Void) {
        // TODO: process errors
        guard let key = Defaults.privateKey else { return }
        let address = "0x" + (try! EthPrivateKey(hex: key).address().value().toHexString())
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
