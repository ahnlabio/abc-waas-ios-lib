import ABCMpc
import Foundation

public enum XRPHelperError: Error {
    case waasError(WaasError)
    case unknownError(String)

    public var description: String {
        switch self {
        case .waasError(let error):
            return "Waas error: \(error.description)"
        case .unknownError(let message):
            return "Unknown error occurred: \(message)"
        }
    }
}

public struct XRPAccount: Codable {
    let account: String
}

public struct XRPBalance: Codable {
    let balance: String
    let available: String
    let reserve: String
}

public struct XRPTransaction: Codable {
    let txHash: String
}

public struct XRPTrustline: Codable {
    let success: Bool
    let account: String
    let issuer: String
    let currency: String
    let trust_line_exists: Bool
    let trust_line_info: XRPTrustlineInfo?
    let error: String?
}

public struct XRPTrustlineInfo: Codable {
    let currency: String
    let issuer: String
    let balance: String
    let limit: String
    let limit_peer: String
    let quality_in: Int
    let quality_out: Int
    let no_ripple: Bool
    let no_ripple_peer: Bool
    let authorized: Bool
    let peer_authorized: Bool
    let freeze: Bool
    let freeze_peer: Bool
}

public struct XRPFtBalance: Codable {
    let success: Bool
    let account: String
    let tokens: [XRPTrustlineInfo]
    let error: String?
}


public class XRPHelper {
    private var waasClient: WaasClient?

    private var node1BaseURL: String
    private var node2BaseURL: String

    public init(waasClient: WaasClient, node1BaseURL: String, node2BaseURL: String) {
        self.waasClient = waasClient
        self.node1BaseURL = node1BaseURL
        self.node2BaseURL = node2BaseURL
    }

    // MARK: - Basic XRP Functions

    public func sign(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, curve: String, message: String) async -> Result<SignResponse, HelperError> {
        // 1. 지갑 토큰 가져오기
        guard let tokenResult = await waasClient?.getV3WalletToken(accessToken: accessToken, id: keyId) else {
            return .failure(HelperError.unknownError("Wallet Data Fetch Failed"))
        }
        
        guard case .success(let walletTokenResponse) = tokenResult else {
            if case .failure(let error) = tokenResult {
                return .failure(HelperError.waasError(error))
            }
            return .failure(HelperError.unknownError("Wallet Data Fetch Failed"))
        }
        
        // 2. 서명
        let signResult = await ABCMpc.sign(node_1_url: self.node1BaseURL, token: walletTokenResponse.token, key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, curve: curve, message: message)
        guard case .success(let signResponse) = signResult else {
            if case .failure(let error) = signResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Message Signing Failed"))
        }
        
        return .success(signResponse)
    }
    
    /// XRP 계정 생성
    public func getAccount(accessToken: String, publicKey: String, network: String) async -> Result<XRPAccount, XRPHelperError> {
        let result = await waasClient?.postV2XrpAccount(accessToken: accessToken, publicKey: publicKey, network: network)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to create XRP account"))
        }


        let parseResult = response.parseWaasResponse(as: XRPAccount.self)
        guard case .success(let account) = parseResult else {
            if case .failure(let error) = parseResult {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to parse XRP account"))
        }
        
        return .success(account)
    }

    /// XRP 잔액 조회
    public func getBalance(accessToken: String, account: String, network: String) async -> Result<XRPBalance, XRPHelperError> {
        let result = await waasClient?.postV2XrpBalance(accessToken: accessToken, account: account, network: network)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to get XRP balance"))
        }

        let parseResult = response.parseWaasResponse(as: XRPBalance.self)
        guard case .success(let balance) = parseResult else {
            if case .failure(let error) = parseResult {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to parse XRP balance"))
        }
        
        return .success(balance)
    }

    // XRP 전송
    public func transferXRP(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, curve: String, account: String, amount: String, destination: String, destinationTag: String?, fee: String?, publicKey: String, network: String) async -> Result<XRPTransaction, XRPHelperError> {

        // fee가 nil이면 기본 수수료 조회
        var finalFee = fee
        if fee == nil {
            let feeResult = await waasClient?.postV2XrpFee(accessToken: accessToken, network: network)
            guard case .success(let feeResponse) = feeResult else {
                if case .failure(let error) = feeResult {
                    return .failure(XRPHelperError.waasError(error))
                }
                return .failure(XRPHelperError.unknownError("Failed to get XRP fee"))
            }

            let feeString = feeResponse.extractValue(path: "raw_fee_data.drops.base_fee") as Result<String, WaasError>
            guard case .success(let feeString) = feeString else {
                return .failure(XRPHelperError.unknownError("Failed to extract fee"))
            }

            finalFee = feeString
        }

        let result = await waasClient?.postV2XrpTransfer(accessToken: accessToken, account: account, amount: amount, destination: destination, destinationTag: destinationTag, fee: finalFee!, publicKey: publicKey, network: network)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to transfer XRP"))
        }

        let serialized_tx = response.extractValue(path: "serialized_tx") as Result<String, WaasError>
        guard case .success(let serializedTx) = serialized_tx else {
            return .failure(XRPHelperError.unknownError("Failed to extract serialized_tx"))
        }

        let hash = response.extractValue(path: "hash") as Result<String, WaasError>
        guard case .success(let hash) = hash else {
            return .failure(XRPHelperError.unknownError("Failed to extract hash"))
        }

        let signResult = await sign(accessToken: accessToken, keyId: keyId, encryptedShare: encryptedShare, secretStore: secretStore, curve: curve, message: hash)
        guard case .success(let signResponse) = signResult else {
            return .failure(XRPHelperError.unknownError("Failed to sign transaction"))
        }

        let sendTransactionResult = await waasClient?.postV2XrpSendTransaction(accessToken: accessToken, publicKey: publicKey, serializedTx: serializedTx, signature: signResponse.signature, network: network)
        guard case .success(let sendTransactionResponse) = sendTransactionResult else {
            return .failure(XRPHelperError.unknownError("Failed to send transaction"))
        }

        let tx_hash = sendTransactionResponse.extractValue(path: "hash") as Result<String, WaasError>
        guard case .success(let txHash) = tx_hash else {
            return .failure(XRPHelperError.unknownError("Failed to extract tx_hash"))
        }

        return .success(XRPTransaction(txHash: txHash))
    }

    // XRP Trustline 조회
    public func getTrustline(accessToken: String, account: String, currency: String, issuer: String, network: String) async -> Result<XRPTrustline, XRPHelperError> {
        let result = await waasClient?.postV2XrpTrustlineStatus(accessToken: accessToken, account: account, currency: currency, issuer: issuer, network: network)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to get XRP trustline status"))
        }

        let parseResult = response.parseWaasResponse(as: XRPTrustline.self)
        guard case .success(let trustline) = parseResult else {
            if case .failure(let error) = parseResult {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to parse XRP trustline status"))
        }

        return .success(trustline)
    }

    // XRP Trustline 설정
    public func setTrustline(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, curve: String, account: String, currency: String, fee: String?, issuer: String, limit: String, publicKey: String, network: String) async -> Result<XRPTransaction, XRPHelperError> {

        var finalFee = fee
        if fee == nil {
            let feeResult = await waasClient?.postV2XrpFee(accessToken: accessToken, network: network)
            guard case .success(let feeResponse) = feeResult else {
                if case .failure(let error) = feeResult {
                    return .failure(XRPHelperError.waasError(error))
                }
                return .failure(XRPHelperError.unknownError("Failed to get XRP fee"))
            }

            let feeString = feeResponse.extractValue(path: "raw_fee_data.drops.base_fee") as Result<String, WaasError>
            guard case .success(let feeString) = feeString else {
                return .failure(XRPHelperError.unknownError("Failed to extract fee"))
            }

            finalFee = feeString
        }

        let result = await waasClient?.postV2XrpTrustline(accessToken: accessToken, account: account, currency: currency, fee: finalFee!, issuer: issuer, limit: limit, publicKey: publicKey, network: network)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to create XRP trustline"))
        }

        let serialized_tx = response.extractValue(path: "serialized_tx") as Result<String, WaasError>
        guard case .success(let serializedTx) = serialized_tx else {
            return .failure(XRPHelperError.unknownError("Failed to extract serialized_tx"))
        }

        let hash = response.extractValue(path: "hash") as Result<String, WaasError>
        guard case .success(let hash) = hash else {
            return .failure(XRPHelperError.unknownError("Failed to extract hash"))
        }

        let signResult = await sign(accessToken: accessToken, keyId: keyId, encryptedShare: encryptedShare, secretStore: secretStore, curve: curve, message: hash)
        guard case .success(let signResponse) = signResult else {
            return .failure(XRPHelperError.unknownError("Failed to sign transaction"))
        }

        let sendTransactionResult = await waasClient?.postV2XrpSendTransaction(accessToken: accessToken, publicKey: publicKey, serializedTx: serializedTx, signature: signResponse.signature, network: network)
        guard case .success(let sendTransactionResponse) = sendTransactionResult else {
            return .failure(XRPHelperError.unknownError("Failed to send transaction"))
        }

        let tx_hash = sendTransactionResponse.extractValue(path: "hash") as Result<String, WaasError>
        guard case .success(let txHash) = tx_hash else {
            return .failure(XRPHelperError.unknownError("Failed to extract tx_hash"))
        }

        return .success(XRPTransaction(txHash: txHash))
    }

    // XRP FT 잔액 조회
    public func getFtBalance(accessToken: String, account: String, issuer: String, network: String) async -> Result<XRPFtBalance, XRPHelperError> {
        let result = await waasClient?.postV2XrpFtBalance(accessToken: accessToken, account: account, issuer: issuer, network: network)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to get XRP FT balance"))    
        }
        
        let parseResult = response.parseWaasResponse(as: XRPFtBalance.self)
        guard case .success(let balance) = parseResult else {
            if case .failure(let error) = parseResult {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to parse XRP FT balance"))
        }

        return .success(balance)
    }
    
    // XRP FT 전송
    public func transferFt(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, curve: String, account: String, amount: String, currency: String, destination: String, destinationTag: String?, fee: String?, issuer: String, publicKey: String, network: String) async -> Result<XRPTransaction, XRPHelperError> {
        var finalFee = fee
        if fee == nil {
            let feeResult = await waasClient?.postV2XrpFee(accessToken: accessToken, network: network)
            guard case .success(let feeResponse) = feeResult else {
                if case .failure(let error) = feeResult {
                    return .failure(XRPHelperError.waasError(error))
                }
                return .failure(XRPHelperError.unknownError("Failed to get XRP fee"))
            }

            let feeString = feeResponse.extractValue(path: "raw_fee_data.drops.base_fee") as Result<String, WaasError>
            guard case .success(let feeString) = feeString else {
                return .failure(XRPHelperError.unknownError("Failed to extract fee"))
            }

            finalFee = feeString
        }

        let result = await waasClient?.postV2XrpFtTransfer(accessToken: accessToken, account: account, amount: amount, currency: currency, destination: destination, destinationTag: destinationTag, fee: finalFee!, issuer: issuer, publicKey: publicKey, network: network)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(XRPHelperError.waasError(error))
            }
            return .failure(XRPHelperError.unknownError("Failed to transfer XRP FT"))
        }

        let serialized_tx = response.extractValue(path: "serialized_tx") as Result<String, WaasError>
        guard case .success(let serializedTx) = serialized_tx else {
            return .failure(XRPHelperError.unknownError("Failed to extract serialized_tx"))
        }

        let hash = response.extractValue(path: "hash") as Result<String, WaasError>
        guard case .success(let hash) = hash else {
            return .failure(XRPHelperError.unknownError("Failed to extract hash"))
        }

        let signResult = await sign(accessToken: accessToken, keyId: keyId, encryptedShare: encryptedShare, secretStore: secretStore, curve: curve, message: hash)
        guard case .success(let signResponse) = signResult else {
            return .failure(XRPHelperError.unknownError("Failed to sign transaction"))
        }

        let sendTransactionResult = await waasClient?.postV2XrpSendTransaction(accessToken: accessToken, publicKey: publicKey, serializedTx: serializedTx, signature: signResponse.signature, network: network)
        guard case .success(let sendTransactionResponse) = sendTransactionResult else {
            return .failure(XRPHelperError.unknownError("Failed to send transaction"))
        }

        let tx_hash = sendTransactionResponse.extractValue(path: "hash") as Result<String, WaasError>
        guard case .success(let txHash) = tx_hash else {
            return .failure(XRPHelperError.unknownError("Failed to extract tx_hash"))
        }

        return .success(XRPTransaction(txHash: txHash))
    }
} 
