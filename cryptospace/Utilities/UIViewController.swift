// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

func instantiate<ViewController: UIViewController>(_ type: ViewController.Type) -> ViewController {
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: type)) as! ViewController
}

extension UIViewController {
    
    func cleanBackButton() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    var inNavigationController: UINavigationController {
        let navigationController = UINavigationController()
        navigationController.viewControllers = [self]
        return navigationController
    }
    
    func addChildViewController(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        view.sendSubviewToBack(child.view)
        child.didMove(toParent: self)
    }
    
    func addChildViewController(_ child: UIViewController, to view: UIView) {
        addChild(child)
        view.addSubviewConstrainedToFrame(child.view)
        view.sendSubviewToBack(child.view)
        child.didMove(toParent: self)
    }
    
    func flashMessage(text: String, image: UIImage = Images.okIndicator, fast: Bool = false) {
        let tag = 999
        if let oldMessageView = view.viewWithTag(tag) {
            oldMessageView.removeFromSuperview()
        }
        
        let messageView = loadNib(MessageView.self)
        messageView.setMessage(text: text, image: image)
        messageView.tag = tag
        messageView.alpha = 0
        messageView.center = view.center
        view.addSubview(messageView)
        UIView.animate(withDuration: 0.1) { [weak messageView] in
            messageView?.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (fast ? 0.75 : 1.25)) { [weak messageView] in
            UIView.animate(withDuration: 0.25, animations: { messageView?.alpha = 0 }) { completed in
                if completed {
                    messageView?.removeFromSuperview()
                }
            }
        }
    }
    
    func endEditingOnTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
}
