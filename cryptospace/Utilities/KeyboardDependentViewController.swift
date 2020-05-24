// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

class KeyboardDependentViewController: UIViewController {
    
    @IBOutlet weak var bottomToSuperviewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomToSafeAreaConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        updateForKeyboard(notification: notification, willHide: false)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        updateForKeyboard(notification: notification, willHide: true)
    }
    
    private func updateForKeyboard(notification: Notification, willHide: Bool) {
        guard let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        let safeAreaOffset = willHide ? 12 : (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height - 16
        let superviewOffset = willHide ? 16 : safeAreaOffset + 32
        
        UIView.animate(withDuration: duration.doubleValue,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(animationCurve.intValue << 16)),
            animations: { [weak self] in
                self?.bottomToSuperviewConstraint.constant = superviewOffset
                self?.bottomToSafeAreaConstraint.constant = safeAreaOffset
                self?.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
}
