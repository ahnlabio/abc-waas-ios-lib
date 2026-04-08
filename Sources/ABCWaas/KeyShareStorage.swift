import Foundation
import Security

/// 저장된 키쉐어 데이터
public struct StoredKeyShare: Codable {
    public let keyId: String
    public let encryptedShare: String
    public let secretStore: String
    public let curve: String

    enum CodingKeys: String, CodingKey {
        case keyId = "key_id"
        case encryptedShare = "encrypted_share"
        case secretStore = "secret_store"
        case curve
    }

    public init(keyId: String, encryptedShare: String, secretStore: String, curve: String) {
        self.keyId = keyId
        self.encryptedShare = encryptedShare
        self.secretStore = secretStore
        self.curve = curve
    }
}

/// Keychain 기반 암호화된 키쉐어 저장소
/// - kSecAttrAccessibleWhenUnlockedThisDeviceOnly: 이 기기에서만 유효, 백업/마이그레이션 제외
/// - Access Group 미설정: 앱 간 공유 불가
public class KeyShareStorage {

    private let serviceName: String
    private let keyPrefix = "keyshare_"
    private let appInstalledKey: String

    public init(serviceName: String = "io.ahnlab.abcwaas.keyshare") {
        self.serviceName = serviceName
        self.appInstalledKey = "\(serviceName).installed"
        clearKeychainOnFreshInstall()
    }

    // MARK: - Fresh Install Detection

    private func clearKeychainOnFreshInstall() {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: appInstalledKey) {
            clear()
            userDefaults.set(true, forKey: appInstalledKey)
            userDefaults.synchronize()
        }
    }

    // MARK: - Public Methods

    /// 키쉐어를 저장합니다.
    /// - Parameter keyShare: 저장할 키쉐어 데이터
    /// - Returns: 저장 성공 여부
    @discardableResult
    public func store(_ keyShare: StoredKeyShare) -> Bool {
        guard let data = try? JSONEncoder().encode(keyShare) else {
            return false
        }
        guard let value = String(data: data, encoding: .utf8) else {
            return false
        }
        return setItem(key: keyPrefix + keyShare.curve, value: value)
    }

    /// 특정 curve의 키쉐어를 조회합니다.
    /// - Parameter curve: 조회할 curve (예: "secp256k1", "ed25519")
    /// - Returns: 저장된 키쉐어 또는 nil
    public func get(curve: String) -> StoredKeyShare? {
        guard let value = getItem(key: keyPrefix + curve),
              let data = value.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(StoredKeyShare.self, from: data)
    }

    /// 특정 curve의 키쉐어를 삭제합니다.
    /// - Parameter curve: 삭제할 curve
    @discardableResult
    public func delete(curve: String) -> Bool {
        return removeItem(key: keyPrefix + curve)
    }

    /// 저장된 모든 키쉐어를 삭제합니다.
    public func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// 특정 curve의 키쉐어가 저장되어 있는지 확인합니다.
    /// - Parameter curve: 확인할 curve
    /// - Returns: 저장 여부
    public func has(curve: String) -> Bool {
        return getItem(key: keyPrefix + curve) != nil
    }

    // MARK: - Private Keychain Methods

    private func setItem(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)

        var newItem = query
        newItem[kSecValueData as String] = data
        newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(newItem as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func getItem(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    private func removeItem(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

}
