//
//  FileStoreUploadManager.swift
//  Vato
//
//  Created by khoi tran on 10/31/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import FwiCore
import FwiCoreRX

final class FileStorageUploadManager {
    
    static let instance = FileStorageUploadManager()
    
    func uploadFileStore(params: [URL: String]) -> Observable<String> {
        return UploadFirebaseStorage.uploadMutiple(files: params).map({ (listUrl) -> String in
            let value = listUrl.compactMap({ $0?.absoluteString }).joined(separator: ";")
            return value
        })
    }
    
    func uploadUploadImage(listImage: [UploadedImage]) -> Observable<String> {
        let events = listImage.map { uploadImage -> Observable<URL?> in
            if let url = uploadImage.getStorageUrl(),
                let path = uploadImage.path {
                return UploadFirebaseStorage.upload(fileURL: url, path: path)
            } else {
                return Observable<URL?>.just(URL(string: uploadImage.imageURL ?? ""))
            }
        }
        return Observable.zip(events).map({ (listUrl) -> String in
            let value = listUrl.compactMap({ $0?.absoluteString }).joined(separator: ";")
            return value
        })
    }
    
    
    func uploadMerchantAttributes(code: String, listImage: [UploadedImage]) -> Observable<MerchantAttributeData> {
        
       return self.uploadUploadImage(listImage: listImage).map { (value) -> MerchantAttributeData in
            var m = MerchantAttributeData()
            m.code = code
            m.data = MerchantAttributeElementData(value: value)
            return m
        }
    }
    
}
