import Foundation

// MARK: - WalletResponse
public struct WalletResponse: Codable {
    public let userId: String
    public let wallets: [Wallet]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case wallets
    }
}

// MARK: - Wallet
public struct Wallet: Codable {
    public let key: Key
    public let address: Address
}

// MARK: - Key
public struct Key: Codable {
    public let curve: String
    public let publicKey: String
    
    enum CodingKeys: String, CodingKey {
        case curve
        case publicKey = "public_key"
    }
}

// MARK: - Address
public struct Address: Codable {
    public let solana: String?
    public let evm: String?
    public let btc: String?
    public let aptos: String?
}

// MARK: - WalletUserResponse
public struct WalletUserResponse: Codable {
    public let userId: String
    public let key: [UserKey]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case key
    }
}

// MARK: - UserKey
public struct UserKey: Codable {
    public let id: String
    public let curve: String
    public let publicKey: String
    public let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case curve
        case publicKey = "public_key"
        case createdAt = "created_at"
    }
}

// MARK: - WalletKeyResponse
public typealias WalletKeyResponse = [UserKey] 
public typealias WalletKey = UserKey

// MARK: - WalletTokenResponse
public struct WalletTokenResponse: Codable {
    public let token: String
}
