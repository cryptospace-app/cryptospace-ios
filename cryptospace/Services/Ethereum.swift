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
    
//    private let contractAddress = EthAddress(hex: "0xd9F3845f8A485d0474Df4bF2F0Fb03e702633F41")
    private let contractAddress = EthAddress(hex: "0x3fdd9353c4b56b9c0ee72083043b3e150f182855")

    init() {
        contractInteractor = Web3ContractInteractor(
            contract: contractAddress,
            network: network
        )
    }
    
    private func getChallengeWinner(id: String) -> String? {
        let signature = "getChallengeWinner(string)"
        let ethString = SimpleString(string: id)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: ethString)
        ])
        if let abiMessage = try? contractInteractor.call(function: functionABI) {
            let winner = try? ABIDecoder().string(message: abiMessage)
            print("winner = \(winner)")
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
        print("bid = ", try! bid.value().toHexString())
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
        print("names = \(names)")
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
        let nameString = SimpleString(string: name)
        let functionABI = EncodedABIFunction(signature: signature, parameters: [
            ABIString(origin: idString),
            ABIString(origin: nameString)
        ])
        let privateKey = EthPrivateKey(hex: Defaults.privateKey!)
        print("bid = ", try! bid.value().toHexString())
        print("function = ", try! functionABI.value().toHexString())
        print("address = ", try! privateKey.address().value().toHexString())
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
        let nameString = SimpleString(string: name)
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
    
    func getBalance(completion: @escaping (Result<String, Error>) -> Void) {
        // TODO: process errors
        guard let key = Defaults.privateKey else { return }
//        let address = String(bytes: try! EthPrivateKey(hex: key).address().value().bytes)
        let address = "0x" + (try! EthPrivateKey(hex: key).address().value().toHexString())
//        let address = String(data: try! EthPrivateKey(hex: key).address().value(), encoding: .utf8)!
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
