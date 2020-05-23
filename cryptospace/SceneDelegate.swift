// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        let navigationController = instantiate(EnterKeyViewController.self).inNavigationController
        if Ethereum.shared.hasAccount && !Defaults.name.isEmpty {
            let enterKahoot = instantiate(EnterKahootViewController.self)
            navigationController.viewControllers.append(enterKahoot)
            
            if let kahootId = Defaults.kahootId {
                let space = instantiate(SpaceViewController.self)
                space.kahootId = kahootId
                navigationController.viewControllers.append(space)
            }
        }
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }

}
