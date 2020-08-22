//
//  StorageManager.swift
//  Vato
// https://medium.com/@sdrzn/swift-4-codable-lets-make-things-even-easier-c793b6cf29e1
//  Created by vato. on 10/19/19.
//  Copyright © 2019 Vato. All rights reserved.
//


import Foundation

public class StorageManager {
    
    fileprivate init() { }
    
    enum Directory {
        case documents
        case caches
    }
    
    /// Returns URL constructed from specified directory
    static fileprivate func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }
    
    
    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            // fatalError(error.localizedDescription)
        }
    }
    
    static func store(_ data: Data, to directory: Directory, path: String, fileName: String) {
        let pathUrl = getURL(for: directory).appendingPathComponent(path)
        let url = pathUrl.appendingPathComponent(fileName)
        
        do {
            if !FileManager.default.fileExists(atPath: pathUrl.path) {
                try FileManager.default.createDirectory(atPath: pathUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        }
        catch {
            // fatalError(error.localizedDescription)
        }
    }
    
    
    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        
        if FileManager.default.fileExists(atPath: url.path),
            let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                // fatalError(error.localizedDescription)
            }
        } else {
            // fatalError("No data at \(url.path)!")
        }
        return nil
        
    }
    
    /// Remove all files at specified directory
    static func clear(_ directory: Directory) {
        let url = getURL(for: directory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            // fatalError(error.localizedDescription)
        }
    }
    
    /// Remove specified file from specified directory
    static func remove(_ fileName: String, from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                // fatalError(error.localizedDescription)
            }
        }
    }
    
    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func fileUrl(_ fileName: String, in directory: Directory) -> URL {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return url
    }
}

@objcMembers class TicketLocalStore: NSObject {
    static let shared = TicketLocalStore()
    override init() {}
    
    static let folderTicket = "buyticket"
    let ticketUser = "\(folderTicket)/ticketuser"
    let ticketOriginlLocation = "\(folderTicket)/ticketoriginlocation"
    let ticketDestLocation = "\(folderTicket)/ticketdestlocation"
    
    func checkExistFolder() {
        let pathUrl = StorageManager.getURL(for: .documents).appendingPathComponent(TicketLocalStore.folderTicket)
        do {
            if !FileManager.default.fileExists(atPath: pathUrl.path) {
                try FileManager.default.createDirectory(atPath: pathUrl.path, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {}
    }
    
     func save(originLocation: TicketLocation, destLocation: TicketLocation) {
        self.checkExistFolder()
        StorageManager.store(originLocation, to: .documents, as: self.ticketOriginlLocation)
        StorageManager.store(destLocation, to: .documents, as: self.ticketDestLocation)
    }
    
    func save(user: TicketUser) {
        self.checkExistFolder()
        StorageManager.store(user , to: .documents, as: self.ticketUser)
    }
    
    func resetDataLocalTicket() {
        do {
            let pathUrl = StorageManager.getURL(for: .documents).appendingPathComponent(TicketLocalStore.folderTicket)
            try? FileManager.default.removeItem(atPath: pathUrl.path)
        } catch {}
    }
    
    func loadDefautUser() -> TicketUser? {
        return StorageManager.retrieve(self.ticketUser, from: .documents, as: TicketUser.self)
    }
    
    func loadDefautOriginLocation() -> TicketLocation? {
        return StorageManager.retrieve(self.ticketOriginlLocation, from: .documents, as: TicketLocation.self)
    }
    
    func loadDefautDestLocation() -> TicketLocation? {
        return StorageManager.retrieve(self.ticketDestLocation, from: .documents, as: TicketLocation.self)
    }
}

