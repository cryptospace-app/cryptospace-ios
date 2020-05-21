// Copyright © 2020 cryptospace. All rights reserved.

import Foundation
import Web3Swift
import BigInt

protocol ContractInteractor {
    
    var network: Web3Swift.Network { get }
    var contract: EthAddress { get }
    
    init(contract: EthAddress, network: Web3Swift.Network)
    
    func call(function: EncodedABIFunction) throws -> ABIMessage
        
    func send(function: EncodedABIFunction, value: EthNumber, sender: PrivateKey) throws -> TransactionHash
}

class Web3ContractInteractor: ContractInteractor {
    
    let network: Web3Swift.Network
    let contract: EthAddress
    
    enum errors: Error {
        case failedToSend
    }
    
    required init(contract: EthAddress, network: Web3Swift.Network) {
        self.contract = contract
        self.network = network
    }
    
    func call(function: EncodedABIFunction) throws -> ABIMessage {
        return try ABIMessage(
            message: EthContractCall(
                network: network,
                contractAddress: contract,
                functionCall: function
            ).value().toHexString()
        )
    }
    
    func send(function: EncodedABIFunction, value: EthNumber, sender: PrivateKey) throws -> TransactionHash {
        
        let response = try SendRawTransactionProcedure(
            network: network,
            transactionBytes: EthContractCallBytes(
                network: network,
                senderKey: sender,
                contractAddress: contract,
                weiAmount: value,
                functionCall: function
            )
        ).call()
        
        guard let hash = response["result"].string else {
            throw errors.failedToSend
        }
        
        return EthTransactionHash(
            network: network, transactionHash: BytesFromHexString(hex: hash)
        )
    }
}
