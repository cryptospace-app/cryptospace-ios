// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

//struct ContractChallenge {
//    let id: String
//    let bidSize: Double
//    let playerNames: [String]
//    let winner: String?
//    let isFinished: Bool
//}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        Ethereum.shared.getChallengeNames(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693")
//        Defaults.privateKey = "0706b63220ad19099db4cf0436eb08e29bad3a1f74d9f2faad4147e44d09b272"
//        Ethereum.shared.createContractChallenge(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693", name: "ivan", bidSize: 0.01) { res in
//            print("res = ", res)
//                    Ethereum.shared.getContractChallenge(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693") { res in
//                        if case let .success(result) = res {
//                            print(result!.id)
//                            print(result!.bidSize)
//                            print(result!.playerNames)
//                            print(result!.winner)
//                            print(result!.isFinished)
//                        }
//                    }
//
//                Ethereum.shared.joinContractChallenge(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693", name: "vadim", bidSize: 0.01) { res in
//                    print("res = ", res)
//                            Ethereum.shared.getContractChallenge(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693") { res in
//                                if case let .success(result) = res {
//                                    print(result!.id)
//                                    print(result!.bidSize)
//                                    print(result!.playerNames)
//                                    print(result!.winner)
//                                    print(result!.isFinished)
//                                }
//                            }
//
//        }
//        Ethereum.shared.getContractChallenge(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693") { res in
//            if case let .success(result) = res {
//                print(result!.id)
//                print(result!.bidSize)
//                print(result!.playerNames)
//                print(result!.winner)
//                print(result!.isFinished)
//            }
//        }
//
//            Ethereum.shared.sendPrize(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693") { res in
//                print("res = ", res)
//                        Ethereum.shared.getContractChallenge(id: "1269fde8-1e13-463b-b93d-6bcf69a83ac2_1589570307693") { res in
//                            if case let .success(result) = res {
//                                print(result!.id)
//                                print(result!.bidSize)
//                                print(result!.playerNames)
//                                print(result!.winner)
//                                print(result!.isFinished)
//                            }
//                        }
//    }
    

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

}

