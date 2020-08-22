import Foundation

extension PaymentMethod: Codable {}
struct FirebaseClient: Codable, ModelFromFireBaseProtocol {
    let active: Bool
    let created: TimeInterval
    var deviceToken: String?
    var payment: PaymentMethod?
    var photo: String?
    let zoneId: Int

    /// Codable's keymap.
    private enum CodingKeys: String, CodingKey {
        case active
        case created
        case deviceToken
        case payment = "paymentMethod"
        case photo
        case zoneId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        active = try container.decode(Bool.self, forKey: .active)
        created = try container.decode(TimeInterval.self, forKey: .created)
        deviceToken = try? container.decode(String.self, forKey: .deviceToken)
        payment = try? container.decode(PaymentMethod.self, forKey: .payment)
        photo = try? container.decode(String.self, forKey: .photo)
        zoneId = try container.decode(Int.self, forKey: .zoneId)
    }

    /// Codable's keymap.
//    private enum CodingKeys: String, CodingKey {
//    }
}

// MARK: ClientProtocol's members
extension FirebaseClient: ClientProtocol {
    var isActive: Bool {
        return active
    }

    var apnsToken: String { return deviceToken ?? "" }

    var zoneID: Int { return zoneId }
    var avatarURL: URL? { return URL(string: photo ?? "") }

    var paymentMethod: PaymentMethod {
        get { return payment ?? PaymentMethodCash }
        set { payment = newValue }
    }
}
