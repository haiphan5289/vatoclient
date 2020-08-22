import Foundation
import FwiCore
import RealmSwift
import RxCocoa
import RxSwift
import UIKit

protocol RealmCollectionView: NSObjectProtocol {
    associatedtype Model: Object

    /// Protocol's required properties
    var collectionView: UICollectionView? { get }

    /// protocol's subscript
    var count: Int { get }
    subscript(index: Int) -> Model? { get }
    subscript(index: IndexPath) -> Model? { get }

    /// Represent a realm model collection that will be binded to collectionView.
    var items: [Model]? { get }
    var collection: Results<Model>? { get }
    var collectionDisposable: Disposable? { get set }

    /// Bind data to collection view.
    func bindData()

    /// Bind collection with notification token. The notification token will handle changed automatically
    /// when the collection had been modified.
    func registerNotification()
}

// MARK: protocol's default subscript
extension RealmCollectionView {
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

// MARK: RealmCollectionView's default implementation
extension RealmCollectionView {
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
                guard let collectionView = self?.collectionView else {
                    return
                }

                switch changes {
                case .initial:
                    collectionView.reloadData()

                case .update(_, let deletions, let insertions, let modifications):
                    collectionView.performBatchUpdates({
                        if insertions.count > 0 {
                            collectionView.insertItems(at: insertions.map({ IndexPath(item: $0, section: 0) }))
                        }

                        if deletions.count > 0 {
                            collectionView.deleteItems(at: deletions.map({ IndexPath(item: $0, section: 0) }))
                        }

                        if modifications.count > 0 {
                            collectionView.reloadItems(at: modifications.map({ IndexPath(item: $0, section: 0) }))
                        }
                    }, completion: nil)

                default:
                    break
                }
            }

            return Disposables.create {
                token?.invalidate()
            }
        }

        guard let event = self.collectionView?.rx.deallocated else {
            return
        }
        collectionDisposable = o.observeOn(MainScheduler.instance)
            .takeUntil(event)
            .subscribe {
                FwiLog("Notification had been removed.")
            }
    }
}
