//  File name   : PromotionNow.swift
//
//  Author      : Dung Vu
//  Created date: 10/29/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct PromotionNow: Codable {
    let manifests: [PromotionList.Manifest]
    let manifestPredicates: [PromotionList.ManifestPredicate]
}

