import Foundation
import RealmSwift
import UIKit

class GenericRealmTableViewCellVM<C: UITableViewCell, M: Object>: GenericRealmTableViewVM<M> {
    /// Initialize cell at index.
    ///
    /// - Parameters:
    ///   - cell: a UICollectionView's cell according to index
    ///   - item: an item at index
    func configure(forCell cell: C, with item: M) {
        fatalError("Child class should override func \(#function)")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = C.dequeueCell(tableView: tableView)
        if let item: M = self[indexPath] {
            configure(forCell: cell, with: item)
        }
        return cell
    }
}
