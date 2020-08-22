
//
//  UploadImageModel.swift
//  Vato
//
//  Created by khoi tran on 10/24/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Kingfisher

protocol StorageImageProtocol {
    var path: String? { get }
    var fileName: String? {get }
}

protocol UploadedImageProtocol {
    
}


extension Source: Equatable {}
public func == (lhs: Source, rhs: Source) -> Bool {
    switch (lhs, rhs) {
    case (.network, .provider):
        return false
    case let (.network(s1), .network(s2)):
        return s1.downloadURL == s2.downloadURL
    default:
        return false
    }
}

enum UploadImagePath {
    case merchantBanner(userId: Int)
    case storeBanner(merchantId: Int)
    case merchantAvatar(userId: Int)
    case quickSupport
    
    func getPath() -> String {
        switch self {
        case .storeBanner(let merchantId):
            return "store/\(merchantId)/"
        case .merchantBanner(let userId):
            return "merchant/\(userId)/"
        case .merchantAvatar(let userId):
            return "images/avatar/merchant/\(userId)/"
        case .quickSupport:
            return "supports/"
        }
    }
}


struct UploadedImage : ImageDisplayProtocol, StorageImageProtocol, UploadedImageProtocol, Equatable {
    var cacheLocal: Bool { return true }
    var path: String?
    var fileName: String?
    var imageURL: String?
    
    
    init() {
        
    }
    
    var sourceImage: Source? {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            
            if let path = path, let fileName = fileName {
                let fullPath = "\(path)\(fileName)"
                if StorageManager.fileExists(fullPath, in: .documents) {
                    let url = StorageManager.fileUrl(fullPath, in: .documents)
                    let provider = LocalFileImageDataProvider(fileURL: url)
                    return .provider(provider)
                } else {
                    return nil
                }
            } else {
                return nil
            }
            
        }
        
        return .network(url)
    }
    
    func removeStorageImage() {
        if let path = path, let fileName = fileName {
            let fullPath = "\(path)\(fileName)"

            if StorageManager.fileExists(fullPath, in: .documents) {
                StorageManager.remove(fullPath, from: .documents)
            }
        }
    }
    
    func saveImage(image: UIImage) {
        guard let path = path, let fileName = fileName else {
            return
        }
        
        if let data = image.jpegData(compressionQuality: 0.7) {
            StorageManager.store(data, to: .documents, path: path, fileName: fileName)
        }
    }
    
    public static func == (lhs: UploadedImage, rhs: UploadedImage) -> Bool {
        return lhs.sourceImage == rhs.sourceImage
    }
    
    
    func getStorageUrl() -> URL? {
        guard let fullPath = self.getFullPath() else {
            return nil
        }
        
        let url = StorageManager.fileUrl(fullPath, in: .documents)
        return url
    }
    
    func getFullPath() -> String? {
        guard let path = path, let fileName = fileName else {
            return nil
        }
        
        let fullPath = "\(path)\(fileName)"
        return fullPath
    }
    
    
}
