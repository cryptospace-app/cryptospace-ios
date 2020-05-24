// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

extension UIButton {
    
    func setWaiting(_ waiting: Bool, activityIndicatorColor: UIColor? = nil) {
        if waiting, inWaitingState { return }
        isUserInteractionEnabled = !waiting
        setTitleColor(waiting ? titleLabel?.textColor.withAlphaComponent(0) : titleLabel?.textColor.withAlphaComponent(1), for: .normal)
        if waiting {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            if let activityIndicatorColor = activityIndicatorColor {
                activityIndicator.color = activityIndicatorColor
            } else {
                activityIndicator.color = .white
            }
            addSubview(activityIndicator)
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            activityIndicator.startAnimating()
        } else {
            for subview in subviews {
                if let activityIndicator = subview as? UIActivityIndicatorView {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }
        }
    }
    
    var inWaitingState: Bool {
        return subviews.contains(where: { $0 is UIActivityIndicatorView })
    }
    
}
