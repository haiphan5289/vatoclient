import Foundation
import FwiCore
import FwiCoreRX
import RealmSwift
import RxSwift
import UIKit

class GenericRealmTableViewVM<T: Object>: FwiTableViewVM, RealmTableView {
    typealias Model = T

    subscript(index: Int) -> Model? {
        guard 0 <= index && index < count else {
            return nil
        }
        return collection?[index] ?? items?[index]
    }

    subscript(index: IndexPath) -> Model? {
        guard 0 <= index.row && index.row < count else {
            return nil
        }
        return collection?[index.row] ?? items?[index.row]
    }

    /// Class's public properties.
    var count: Int {
        return collection?.count ?? items?.count ?? 0
    }

    let currentItemSubject = ReplaySubject<Model?>.create(bufferSize: 1)
    private(set) var currentItem: Model? {
        didSet {
            currentItemSubject.on(.next(currentItem))
        }
    }

    /// Class's destructor
    deinit {
        collectionDisposable?.dispose()
        collectionDisposable = nil
        collection = nil
        items = nil
    }

    // MARK: Class's public methods
    override func setupRX() {
        super.setupRX()
        bindData()
        registerNotification()
    }

    // MARK: RealmTableView's members
    func bindData() {
        fatalError("Child class should override func \(#function)")
    }

    // MARK: UITableViewDataSource's members
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }

    // MARK: UITableViewDelegate's members
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentItem = self[indexPath]
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        currentItem = nil
    }

    /// Class's private properties.
    internal var items: [Model]?
    internal var collection: Results<Model>?
    internal var collectionDisposable: Disposable?
}
