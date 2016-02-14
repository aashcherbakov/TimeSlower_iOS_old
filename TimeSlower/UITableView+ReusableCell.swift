//
//  UITableViewReusableCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/13/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Defines a reusable table view or collection view cell.
public protocol ReusableViewCell: class {
    
    /// Default reuse identifier is set with the class name.
    static var reuseIdentifier: String { get }
}

public extension ReusableViewCell {
    
    /// Default reuse identifier is set with the class name.
    static var reuseIdentifier: String {
        return String(self.dynamicType).componentsSeparatedByString(".").last!
    }
}

extension UITableViewCell: ReusableViewCell { }
extension UICollectionViewCell: ReusableViewCell { }

public extension UITableView {
    
    /**
     Dequeues a reusable table view cell from the table view for use.

     - returns: The table view cell.
     */
    public func dequeueReusableCell<T: ReusableViewCell>() -> T {
        guard let cell = self.dequeueReusableCellWithIdentifier(T.reuseIdentifier) as? T else {
                fatalError("No table view cell could be dequeued with identifier \(T.reuseIdentifier)")
            }
        return cell
    }
}
