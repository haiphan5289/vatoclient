//
//  FireBaseModel.swift
//  Vato
//
//  Created by khoi tran on 4/1/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FirebaseModel {
}

typealias CollectionValuesChanges = [DocumentChangeType: [QueryDocumentSnapshot]]

struct DocumentChangeModel {
    var documentsDelete: [QueryDocumentSnapshot]?
    var documentsAdd: [QueryDocumentSnapshot]?
    var documentsChange: [QueryDocumentSnapshot]?
    
    init(values: CollectionValuesChanges) {
        documentsDelete = values[.removed]
        documentsAdd = values[.added]
        documentsChange = values[.modified]
    }
}
