// Copyright © 2020 cryptospace. All rights reserved.

import UIKit

extension UITableView {
    
    func dequeueReusableCellOfType<CellType: UITableViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        let cellName = String(describing: type)
        register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
        return dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! CellType
    }
    
    func dequeueReusableHeaderFooterOfType<HeaderType: UITableViewHeaderFooterView>(_ type: HeaderType.Type) -> HeaderType {
        let headerFooterName = String(describing: type)
        register(UINib(nibName: headerFooterName, bundle: nil), forHeaderFooterViewReuseIdentifier: headerFooterName)
        return dequeueReusableHeaderFooterView(withIdentifier: headerFooterName) as! HeaderType
    }
    
}
