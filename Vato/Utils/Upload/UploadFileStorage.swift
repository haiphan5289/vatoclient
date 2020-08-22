//  File name   : UploadFileStorage.swift
//
//  Author      : Dung Vu
//  Created date: 10/24/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import FirebaseStorage
import Alamofire
import VatoNetwork

struct UploadFirebaseStorage {
    static func detele(path: String) -> Observable<Void> {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: path)
        return Observable.create({ (s) -> Disposable in
            storageRef.delete { (e) in
                if let e = e {
                    s.onError(e)
                } else {
                    s.onNext(())
                    s.onCompleted()
                }
            }
            return Disposables.create()
            
        })
    }
    
    
    
    static func upload(fileURL: URL, path: String) -> Observable<URL?> {
        
        guard let token = FirebaseTokenHelper.instance.token else {
            return Observable.error(NSError.init(domain: "Invalid token", code: 0, userInfo: nil))
        }
        let headers = [
            "x-access-token": token,
            "Content-Type":"multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__",
        ]
        
        let filename = fileURL.lastPathComponent
        let urlLink = VatoFoodApi.uploadHost + "/image/uploadFile"
        // Fetch Request
        let h = HTTPHeaders(with: headers)
        
        return Observable.create { (s) -> Disposable in
            do {
                let data = try Data(contentsOf: fileURL)
                let task = Alamofire.Session.default.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(path.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"targetPath")
                    multipartFormData.append(data, withName: "file", fileName: filename, mimeType: "image/jpg")
                }, to: urlLink, usingThreshold: 10*1024000, method: .post, headers: h)
                
                task.responseJSON { (response) in
                    switch response.result {
                    case .success(let value):
                        if let value: JSON = value as? JSON {
                            if let urlString: String = value.value("fileDownloadUri", defaultValue: nil), let url = URL(string: urlString) {
                                s.onNext(url)
                                s.onCompleted()
                            } else {
                                let e = NSError.init(domain: "Error: Parsing upload image error", code: 0, userInfo: nil)
                                s.onError(e)
                            }
                        } else {
                            let e = NSError.init(domain: "Error: Parsing upload image error", code: 0, userInfo: nil)
                            s.onError(e)
                        }
                    case .failure(let e):
                        s.onError(e)
                    }
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            } catch {
                s.onError(error)
                return Disposables.create {}
            }
            
        }.observeOn(SerialDispatchQueueScheduler(qos: .background))
        
    }
    
    static func uploadMutiple(files: [URL: String]) -> Observable<[URL?]> {
        let events = files.map { item -> Observable<URL?> in
            return self.upload(fileURL: item.key, path: item.value)
        }
        return Observable.zip(events)
    }
    
    static func uploadFireStoreMutiple(images: [UIImage], folderName: String) -> Observable<[URL?]> {
        if images.isEmpty { return Observable.empty() }
        let events = images.enumerated().compactMap { item -> Observable<URL?> in
            guard let data = item.element.jpegData(compressionQuality: 0.5) else { return Observable.empty() }
            let path = "images/\(folderName)/\(item.offset)_\(Date().timeIntervalSince1970)"
            return self.uploadFireStore(data: data, path: path)
        }
        return Observable.zip(events)
    }
    
    static func uploadFireStore(data: Data, path: String) -> Observable<URL?> {
        let storage = Storage.storage()
        let storageRef = storage.reference(withPath: path)
        return Observable.create { (s) -> Disposable in
            var task: StorageUploadTask?
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            task = storageRef.putData(data, metadata: metadata, completion: { _, e in
                if let e = e {
                    s.onError(e)
                } else {
                    storageRef.downloadURL(completion: { url, e1 in
                        if let e1 = e1 {
                            s.onError(e1)
                        } else {
                            s.onNext(url)
                            s.onCompleted()
                        }
                    })
                }
            })
            return Disposables.create {
                task?.cancel()
            }
        }.observeOn(SerialDispatchQueueScheduler(qos: .background))
    }
}


