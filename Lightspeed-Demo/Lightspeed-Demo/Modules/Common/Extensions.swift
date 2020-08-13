//
//  Extensions.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation
import UIKit

protocol Presenter: AnyObject {
    func load()
}

protocol View: AnyObject {
    func displayAlert(title: String?, message: String, handler: ((UIAlertAction) -> Void)?)
}

extension UIViewController: View {
    func displayAlert(title: String?, message: String, handler: ((UIAlertAction) -> Void)?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button title"), style: UIAlertAction.Style.default, handler: handler))
        controller.view.tintColor = .systemBlue
        DispatchQueue.main.async { [weak self] () -> Void in
            self?.present(controller, animated: true, completion: nil)
        }
    }
}

protocol Reusable: AnyObject {
    static var identifier: String { get }
}

extension Reusable {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as? T else {
            fatalError("Couldn't dequeue cell of type \(type) using identifier \(type.identifier)")
        }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(ofType type: T.Type) -> T? {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: type.identifier) as? T else {
            fatalError("Couldn't dequeue header/footer view of type \(type) using identifier \(type.identifier)")
        }
        return view
    }
    
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType.self, forCellReuseIdentifier: cellType.identifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(_ cellType: T.Type) {
        register(cellType.self, forHeaderFooterViewReuseIdentifier: cellType.identifier)
    }
}

extension Optional {
    func orThrow(_ errorExpression: @autoclosure () -> Error) throws -> Wrapped {
        guard let value = self else {
            throw errorExpression()
        }
        return value
    }
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
