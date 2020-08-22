import Foundation

struct FirebaseUser: Codable, ModelFromFireBaseProtocol, ImageDisplayProtocol {
    var imageURL: String? {
        return avatarUrl
    }
    
    let cash: Double
    let coin: Double
    var email: String?
    let firebaseId: String
    var fullName: String?
    let id: Int64
    var nickName: String?
    let phone: String
    var avatarUrl: String?
    var cacheLocal: Bool { return true }
    var displayName: String? {
        return self.nickName ?? self.fullName
    }
}

// MARK: UserProtocol's members
extension FirebaseUser: UserProtocol {
    var firebaseID: String { return firebaseId }
    var userID: Int64 { return id }

    var fullname: String? { return fullName }
    var nickname: String? { return nickName }

    var emailAddress: String { return email ?? "" }
    var photoURL: URL? { return URL(string: avatarUrl ?? "") }
}

extension FirebaseUser: UserDisplayProtocol {}
