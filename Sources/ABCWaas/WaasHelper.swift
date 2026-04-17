import ABCMpc
import Foundation

public enum HelperError: Error {
    case waasError(WaasError)
    case mpcError(MpcError)
    case unknownError(String)

    public var description: String {
        switch self {
        case .waasError(let error):
            return "Waas error: \(error.description)"
        case .mpcError(let error):
            return "Mpc error: \(error.description)"
        case .unknownError(let message):
            return "Unknown error occurred: \(message)"
        }
    }
}

public class WaasHelper {
    private var waasClient: WaasClient?

    private var node1BaseURL: String
    private var node2BaseURL: String
    private var keyShareStorage: KeyShareStorage?

    public init(waasClient: WaasClient, node1BaseURL: String, node2BaseURL: String, keyShareStorage: KeyShareStorage? = nil) {
        self.waasClient = waasClient
        self.node1BaseURL = node1BaseURL
        self.node2BaseURL = node2BaseURL
        self.keyShareStorage = keyShareStorage
    }

    public func generateKeyShare(accessToken: String, curve: String, password: String) async -> Result<GenerateShareResponse, HelperError> {
        // 1. User 키 존재 확인
        let userKeyResult = await waasClient?.getV3WalletKey(accessToken: accessToken)
        guard case .success(let walletKeyResponse) = userKeyResult else {
            if case .failure(let error) = userKeyResult {
                return .failure(HelperError.waasError(error))
            }
            return .failure(HelperError.unknownError("Wallet data fetch failed"))
        }
        
        let curveKeyResult = checkForDuplicateKey(walletKeyResponse: walletKeyResponse, curve: curve)
        if case .failure(let error) = curveKeyResult {
            return .failure(error)
        }

        // 2. 키 ID 생성
        let keyIdResult = await generate_key_id()
        guard case .success(let keyIdResponse) = keyIdResult else {
            if case .failure(let error) = keyIdResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Key ID generation failed"))
        }
        
        // 3. 지갑 토큰 가져오기
        guard let tokenResult = await waasClient?.getV3WalletToken(accessToken: accessToken, id: keyIdResponse.result) else {
            return .failure(HelperError.unknownError("Wallet Token Fetch Failed"))
        }
        
        guard case .success(let walletTokenResponse) = tokenResult else {
            if case .failure(let error) = tokenResult {
                return .failure(HelperError.waasError(error))
            }
            return .failure(HelperError.unknownError("Wallet Token Fetch Failed"))
        }
        
        // 4. 쉐어 생성
        let generateShareResult = await generate_share(
            node_1_url: self.node1BaseURL,
            node_2_url: self.node2BaseURL,
            auth_token: accessToken,
            mpc_token: walletTokenResponse.token,
            key_id: keyIdResponse.result,
            curve: curve,
            password: password
        )
        
        guard case .success(let generateShareResponse) = generateShareResult else {
            if case .failure(let error) = generateShareResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Key Share Generation Failed"))
        }
        
        // 5. 공개 키 생성
        let publicKeyResult = await public_key(
            key_id: generateShareResponse.keyId,
            encrypted_share: generateShareResponse.encryptedShare,
            secret_store: generateShareResponse.secretStore,
            curve: generateShareResponse.curve,
            password: password
        )
        
        guard case .success(let publicKeyResponse) = publicKeyResult else {
            if case .failure(let error) = publicKeyResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Public Key Generation Failed"))
        }
        
        // 6. 지갑 키 등록
        let postWalletResult = await waasClient?.postV3WalletKey(
            accessToken: accessToken,
            id: generateShareResponse.keyId,
            curve: generateShareResponse.curve,
            publicKey: publicKeyResponse.result
        )
        
        guard case .success(let walletKey) = postWalletResult else {
            if case .failure(let error) = postWalletResult {
                return .failure(HelperError.waasError(error))
            }
            return .failure(HelperError.unknownError("Wallet Key Registration Failed"))
        }
        
        // 7. 성공 처리
        return .success(generateShareResponse)
    }

    /// 키쉐어를 생성하고 로컬 보안 저장소에 자동 저장합니다.
    /// KeyShareStorage가 설정되어 있어야 합니다.
    public func generateAndStoreKeyShare(accessToken: String, curve: String, password: String) async -> Result<GenerateShareResponse, HelperError> {
        guard let storage = keyShareStorage else {
            return .failure(.unknownError("KeyShareStorage is not initialized"))
        }

        let result = await generateKeyShare(accessToken: accessToken, curve: curve, password: password)
        if case .success(let response) = result {
            storage.store(StoredKeyShare(
                keyId: response.keyId,
                encryptedShare: response.encryptedShare,
                secretStore: response.secretStore,
                curve: response.curve
            ))
        }
        return result
    }

    /// 키쉐어를 복구하고 로컬 보안 저장소에 자동 저장합니다.
    /// KeyShareStorage가 설정되어 있어야 합니다.
    public func recoverAndStoreKeyShare(accessToken: String, curve: String, password: String) async -> Result<RecoverShareResponse, HelperError> {
        guard let storage = keyShareStorage else {
            return .failure(.unknownError("KeyShareStorage is not initialized"))
        }

        let result = await recoverKeyShare(accessToken: accessToken, curve: curve, password: password)
        if case .success(let response) = result {
            storage.store(StoredKeyShare(
                keyId: response.keyId,
                encryptedShare: response.encryptedShare,
                secretStore: response.secretStore,
                curve: response.curve
            ))
        }
        return result
    }

    /// 로컬 보안 저장소에서 키쉐어를 조회합니다.
    public func getStoredKeyShare(curve: String) -> StoredKeyShare? {
        return keyShareStorage?.get(curve: curve)
    }

    /// 로컬 보안 저장소에서 키쉐어를 삭제합니다.
    @discardableResult
    public func deleteStoredKeyShare(curve: String) -> Bool {
        return keyShareStorage?.delete(curve: curve) ?? false
    }

    /// 로컬 보안 저장소에서 모든 키쉐어를 삭제합니다.
    public func clearStoredKeyShares() {
        keyShareStorage?.clear()
    }

    public func recoverKeyShare(accessToken: String, curve: String, password: String) async -> Result<RecoverShareResponse, HelperError> {
        // 1. User 키 존재 확인
        let userKeyResult = await waasClient?.getV3WalletKey(accessToken: accessToken)
        guard case .success(let walletKeyResponse) = userKeyResult else {
            if case .failure(let error) = userKeyResult {
                return .failure(HelperError.waasError(error))
            }
            return .failure(HelperError.unknownError("Wallet data fetch failed"))
        }
        
        var foundMatchingKey = false
        var source_key_id: String = ""
        for key in walletKeyResponse {
            if key.curve == curve {
                // 일치하는 키를 찾은 경우
                foundMatchingKey = true
                source_key_id = key.id
                break  // 일치하는 키를 찾았으므로 루프 종료
            }
        }
        
        // 일치하는 키를 찾지 못한 경우
        if !foundMatchingKey {
            return .failure(HelperError.unknownError("No key found with the specified curve and key_id"))
        }
        
        let curveKeyResult = checkForRequiredKey(walletKeyResponse: walletKeyResponse, curve: curve)
        if case .failure(let error) = curveKeyResult {
            return .failure(error)
        }
        
        // 2. 키 ID 생성
        let keyIdResult = await generate_key_id()
        guard case .success(let keyIdResponse) = keyIdResult else {
            if case .failure(let error) = keyIdResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Key ID generation failed"))
        }
        
        // 3. 지갑 토큰 가져오기
        guard let tokenResult = await waasClient?.getV3WalletToken(accessToken: accessToken, id: keyIdResponse.result) else {
            return .failure(HelperError.unknownError("Wallet Token Fetch Failed"))
        }
        
        guard case .success(let walletTokenResponse) = tokenResult else {
            if case .failure(let error) = tokenResult {
                return .failure(HelperError.waasError(error))
            }
            return .failure(HelperError.unknownError("Wallet Token Fetch Failed"))
        }
        
        // 4. 쉐어 생성
        let reoverShareResult = await recover_share(
            node_1_url: self.node1BaseURL,
            node_2_url: self.node2BaseURL,
            auth_token: accessToken,
            mpc_token: walletTokenResponse.token,
            target_key_id: keyIdResponse.result,
            source_key_id: source_key_id,
            curve: curve,
            password: password
        )
        
        guard case .success(let recoverShareResponse) = reoverShareResult else {
            if case .failure(let error) = reoverShareResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Key Share Recovery Failed"))
        }
        
        // 5. 공개 키 생성
        let publicKeyResult = await public_key(
            key_id: recoverShareResponse.keyId,
            encrypted_share: recoverShareResponse.encryptedShare,
            secret_store: recoverShareResponse.secretStore,
            curve: recoverShareResponse.curve,
            password: password
        )
        
        guard case .success(let publicKeyResponse) = publicKeyResult else {
            if case .failure(let error) = publicKeyResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Public Key Generation Failed"))
        }
        
        // 6. 지갑 키 등록
        let postWalletResult = await waasClient?.postV3WalletKey(
            accessToken: accessToken,
            id: recoverShareResponse.keyId,
            curve: recoverShareResponse.curve,
            publicKey: publicKeyResponse.result
        )
        
        guard case .success(let walletKey) = postWalletResult else {
            if case .failure(let error) = postWalletResult {
                return .failure(HelperError.waasError(error))
            }
            return .failure(HelperError.unknownError("Wallet Key Registration Failed"))
        }
        
        // 7. 성공 처리
        return .success(recoverShareResponse)
    }

    public func sign(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, curve: String, message: String, password: String) async -> Result<SignResponse, HelperError> {
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

        // 2. 서명 (secp256k1은 자동으로 MTA 서명 사용)
        let signResult: Result<SignResponse, MpcError>
        if curve == "secp256k1" {
            signResult = await ABCMpc.sign_mta(node_1_url: self.node1BaseURL, auth_token: accessToken, mpc_token: walletTokenResponse.token, key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, message: message, password: password)
        } else {
            signResult = await ABCMpc.sign(node_1_url: self.node1BaseURL, auth_token: accessToken, mpc_token: walletTokenResponse.token, key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, curve: curve, message: message, password: password)
        }
        guard case .success(let signResponse) = signResult else {
            if case .failure(let error) = signResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Message Signing Failed"))
        }

        return .success(signResponse)
    }

    public func signMta(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, message: String, password: String) async -> Result<SignResponse, HelperError> {
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

        // 2. MTA 서명
        let signResult = await ABCMpc.sign_mta(node_1_url: self.node1BaseURL, auth_token: accessToken, mpc_token: walletTokenResponse.token, key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, message: message, password: password)
        guard case .success(let signResponse) = signResult else {
            if case .failure(let error) = signResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("MTA Message Signing Failed"))
        }

        return .success(signResponse)
    }

    public func signMtaDerived(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, message: String, chainCode: String, path: String, password: String) async -> Result<SignResponse, HelperError> {
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

        // 2. MTA 파생 서명
        let signResult = await ABCMpc.sign_mta_derived(node_1_url: self.node1BaseURL, auth_token: accessToken, mpc_token: walletTokenResponse.token, key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, message: message, chain_code: chainCode, path: path, password: password)
        guard case .success(let signResponse) = signResult else {
            if case .failure(let error) = signResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("MTA Derived Message Signing Failed"))
        }

        return .success(signResponse)
    }

    public func signWithChainCode(accessToken: String, keyId: String, encryptedShare: String, secretStore: String, curve: String, message: String, chainCode: String, path: String, password: String) async -> Result<SignResponse, HelperError> {
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

        // 2. 체인코드 파생 서명 (secp256k1은 자동으로 MTA 파생 서명 사용)
        let signResult: Result<SignResponse, MpcError>
        if curve == "secp256k1" {
            signResult = await ABCMpc.sign_mta_derived(node_1_url: self.node1BaseURL, auth_token: accessToken, mpc_token: walletTokenResponse.token, key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, message: message, chain_code: chainCode, path: path, password: password)
        } else {
            signResult = await ABCMpc.sign_with_chain_code(node_1_url: self.node1BaseURL, auth_token: accessToken, mpc_token: walletTokenResponse.token, key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, curve: curve, message: message, chain_code: chainCode, path: path, password: password)
        }
        guard case .success(let signResponse) = signResult else {
            if case .failure(let error) = signResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("ChainCode Derived Message Signing Failed"))
        }

        return .success(signResponse)
    }

    /// 저장된 키쉐어를 사용하여 서명합니다.
    public func signWithStoredKeyShare(accessToken: String, curve: String, message: String, password: String) async -> Result<SignResponse, HelperError> {
        guard let stored = keyShareStorage?.get(curve: curve) else {
            return .failure(.unknownError("No stored key share found for curve: \(curve)"))
        }
        return await sign(accessToken: accessToken, keyId: stored.keyId, encryptedShare: stored.encryptedShare, secretStore: stored.secretStore, curve: curve, message: message, password: password)
    }

    /// 저장된 키쉐어를 사용하여 MTA 서명합니다.
    public func signMtaWithStoredKeyShare(accessToken: String, curve: String, message: String, password: String) async -> Result<SignResponse, HelperError> {
        guard let stored = keyShareStorage?.get(curve: curve) else {
            return .failure(.unknownError("No stored key share found for curve: \(curve)"))
        }
        return await signMta(accessToken: accessToken, keyId: stored.keyId, encryptedShare: stored.encryptedShare, secretStore: stored.secretStore, message: message, password: password)
    }

    /// 저장된 키쉐어를 사용하여 MTA 파생 서명합니다.
    public func signMtaDerivedWithStoredKeyShare(accessToken: String, curve: String, message: String, chainCode: String, path: String, password: String) async -> Result<SignResponse, HelperError> {
        guard let stored = keyShareStorage?.get(curve: curve) else {
            return .failure(.unknownError("No stored key share found for curve: \(curve)"))
        }
        return await signMtaDerived(accessToken: accessToken, keyId: stored.keyId, encryptedShare: stored.encryptedShare, secretStore: stored.secretStore, message: message, chainCode: chainCode, path: path, password: password)
    }

    /// 저장된 키쉐어를 사용하여 체인코드 파생 서명합니다.
    public func signWithChainCodeWithStoredKeyShare(accessToken: String, curve: String, message: String, chainCode: String, path: String, password: String) async -> Result<SignResponse, HelperError> {
        guard let stored = keyShareStorage?.get(curve: curve) else {
            return .failure(.unknownError("No stored key share found for curve: \(curve)"))
        }
        return await signWithChainCode(accessToken: accessToken, keyId: stored.keyId, encryptedShare: stored.encryptedShare, secretStore: stored.secretStore, curve: curve, message: message, chainCode: chainCode, path: path, password: password)
    }

    public func publicKeyWithChainCode(keyId: String, encryptedShare: String, secretStore: String, curve: String, chainCode: String, path: String, password: String) async -> Result<PublicKeyResponse, HelperError> {
        let publicKeyResult = await ABCMpc.public_key_with_chain_code(key_id: keyId, encrypted_share: encryptedShare, secret_store: secretStore, curve: curve, chain_code: chainCode, path: path, password: password)
        guard case .success(let publicKeyResponse) = publicKeyResult else {
            if case .failure(let error) = publicKeyResult {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Public Key With ChainCode Generation Failed"))
        }

        return .success(publicKeyResponse)
    }

    public func validatePassword(password: String, secretStore: String) async -> Result<ValidatePasswordAndSecretStoreResponse, HelperError> {
        let result = await ABCMpc.validate_password_and_secret_store(password: password, secret_store:secretStore)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Password Validation Failed"))
        }
        
        return .success(response)
    }
    
    public func validateShare(encryptedShare: String, secretStore: String, password: String) async -> Result<ValidateShareAndSecretStoreResponse, HelperError> {
        let result = await ABCMpc.validate_share_and_secret_store(encrypted_share: encryptedShare, secret_store: secretStore, password: password)
        guard case .success(let response) = result else {
            if case .failure(let error) = result {
                return .failure(HelperError.mpcError(error))
            }
            return .failure(HelperError.unknownError("Share Validation Failed"))
        }
        
        return .success(response)
    }

    // 1. 중복 키 확인 (키가 이미 존재하면 에러 반환)
    func checkForDuplicateKey(walletKeyResponse: WalletKeyResponse, curve: String) -> Result<Void, HelperError> {
        // walletKeyResponse 배열에서 주어진 curve와 일치하는 요소가 있는지 확인
        if walletKeyResponse.contains(where: { $0.curve == curve }) {
            // 이미 존재하는 경우 에러 반환
            // return .failure(AppError.init(message: "\(curve) key already exists for this user. Cannot create duplicate key"))
            return .failure(HelperError.waasError(WaasError.operationFailed("\(curve) key already exists for this user. Cannot create duplicate key")))
        }
        
        // 존재하지 않는 경우 성공 반환
        return .success(())
    }

    // 2. 필요한 키 확인 (키가 존재하지 않으면 에러 반환)
    func checkForRequiredKey(walletKeyResponse: WalletKeyResponse, curve: String) -> Result<Void, HelperError> {
        // walletKeyResponse 배열에서 주어진 curve와 일치하는 요소가 있는지 확인
        if !walletKeyResponse.contains(where: { $0.curve == curve }) {
            // 존재하지 않는 경우 에러 반환
            // return .failure(AppError.init(message: "No \(curve) key exists for this user. Please create the key first."))
            return .failure(HelperError.waasError(WaasError.operationFailed("No \(curve) key exists for this user. Please create the key first.")))
        }
        
        // 존재하는 경우 성공 반환
        return .success(())
    }
}
