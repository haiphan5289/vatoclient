import Foundation
import FwiCore
import RealmSwift
import RxCocoa
import RxSwift
import UIKit

protocol RealmTableView: NSObjectProtocol {
    associatedtype Model: Object

    /// Protocol's required properties
    var tableView: UITableView? { get }

    /// Protocol's subscript
    var count: Int { get }
    subscript(index: Int) -> Model? { get }
    subscript(index: IndexPath) -> Model? { get }

    /// Represent a realm model collection that will be binded to tableView.
    var items: [Model]? { get }
    var collection: Results<Model>? { get }
    var collectionDisposable: Disposable? { get set }

    /// Bind data to table view.
    func bindData()

    /// Bind collection with notification token. The notification token will handle changed automatically
    /// when the collection had been modified.
    func registerNotification()
}

// MARK: protocol's default subscript
extension RealmTableView {
    var count: Int {
        if items != nil {
            return items?.count ?? 0
        }
        return collection?.count ?? 0
    }

    subscript(index: Int) -> Model? {
        guard 0 <= index && index < count else {
            return nil
        }

        if items != nil {
            return items?[index]
        }
        return collection?[index]
    }

    subscript(index: IndexPath) -> Model? {
        guard 0 <= index.row && index.row < count else {
            return nil
        }

        if items != nil {
            return items?[index.row]
        }
        return collection?[index.row]
    }
}

// MARK: RealmTableView's default implementation
extension RealmTableView {
    var items: [Model]? {
        return nil
    }

    func registerNotification() {
        guard collection != nil else {
            return
        }

        // Release previous notification
        collectionDisposable?.dispose()
        collectionDisposable = nil

        // Register new notification
        let o = Observable<NotificationToken?>.create { [weak self] observer in
            let token = self?.collection?.observe { changes in
                guard let tableView = self?.tableView else {
                    return
                }

                switch changes {
                case .initial:
                    tableView.reloadData()

                case .update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    defer { tableView.endUpdates() }

                    if insertions.count > 0 {
                        tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .fade)
                    }

                    if deletions.count > 0 {
                        tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .fade)
                    }

                    if modifications.count > 0 {
                        tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .fade)
                    }

                default:
                    break
                }
            }

            return Disposables.create {
                token?.invalidate()
            }
        }

        // Observe change
        guard let event = self.tableView?.rx.deallocated else {
            return
        }

        collectionDisposable = o.observeOn(MainScheduler.instance)
            .takeUntil(event)
            .subscribe {
                FwiLog("Notification had been removed.")
            }
    }
}
