// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

extension UICollectionView {
    
    func dequeueReusableCellOfType<Cell: UICollectionViewCell>(_ type: Cell.Type, for indexPath: IndexPath) -> Cell {
        let cellName = String(describing: type)
        register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        return dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! Cell
    }
    
    func dequeueSupplementaryView<View: UICollectionReusableView>(type: View.Type, fromStoryboard: Bool, kind: String, for indexPath: IndexPath) -> View {
        let identifier = String(describing: type)
        if fromStoryboard { register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier) }
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! View
    }
    
}
