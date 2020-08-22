//  File name   : ImageVatoDiskCache.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import SDWebImage
import FwiCore

@objcMembers
final class ImageVatoDiskCache: SDDiskCache {
    /// Class's public properties.
    
    private var identifier = "com.vato.image/default"
    /// Class's private properties.
    required init?(cachePath: String, config: SDImageCacheConfig) {
        let url = URL.documentDirectory()?.appendingPathComponent(identifier).path ?? cachePath
        super.init(cachePath: url, config: config)
    }
}

