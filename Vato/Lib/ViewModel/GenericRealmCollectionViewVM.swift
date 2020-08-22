import Foundation
import FwiCore
import FwiCoreRX
import RealmSwift
import RxSwift
import UIKit

class GenericRealmCollectionViewVM<T: Object>: FwiCollectionViewVM, RealmCollectionView {
    typealias Model = T

    // MARK: Class's properties
    /// Override default implementation
    var count: Int {
        return collection?.count ?? items?.count ?? 0
    }

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

    /// Class's variables.
    let currentItemSubject = ReplaySubject<Model?>.create(bufferSize: 1)
    private(set) var currentItem: Model? {
        didSet {
            currentItemSubject.on(.next(currentItem))
        }
    }

    internal var items: [Model]?
    internal var collection: Results<Model>?
    internal var collectionDisposable: Disposable?

    // MARK: Class's destructor
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

    // MARK: RealmCollectionView's members
    func bindData() {
        fatalError("Child class should override func \(#function)")
    }

    // MARK: UICollectionViewDataSource's members
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }

    // MARK: UICollectionViewDelegate's members
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentItem = self[indexPath]
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        currentItem = nil
    }
}
