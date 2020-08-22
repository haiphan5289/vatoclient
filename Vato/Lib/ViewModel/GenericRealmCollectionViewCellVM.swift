import Foundation
import RealmSwift
import UIKit

class GenericRealmCollectionViewCellVM<C: UICollectionViewCell, M: Object>: GenericRealmCollectionViewVM<M> {
    /// Initialize cell at index.
    ///
    /// - Parameters:
    ///   - cell: a UICollectionView's cell according to index
    ///   - item: an item at index
    func configure(forCell cell: C, with item: M) {
        fatalError("Child class should override func \(#function)")
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = C.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        if let item: M = self[indexPath] {
            configure(forCell: cell, with: item)
        }
        return cell
    }
}
