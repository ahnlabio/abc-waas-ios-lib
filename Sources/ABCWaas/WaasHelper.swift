import ABCMpc

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

    public init(waasClient: WaasClient, node1BaseURL: String, node2BaseURL: String) {
        self.waasClient = waasClient
        self.node1BaseURL = node1BaseURL
        self.node2BaseURL = node2BaseURL
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
            key_id: keyIdResponse.result,
            token: walletTokenResponse.token,
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
            curve: generateShareResponse.curve
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
            token: walletTokenResponse.token,
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
            curve: recoverShareResponse.curve
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
    
    public func validateShare(encryptedShare: String, secretStore: String) async -> Result<ValidateShareAndSecretStoreResponse, HelperError> {
        let result = await ABCMpc.validate_share_and_secret_store(encrypted_share: encryptedShare,secret_store: secretStore)
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