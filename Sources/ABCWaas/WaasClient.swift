import Foundation
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin
#else
import Glibc
#endif

@_silgen_name("waas_client_create")
private func waas_client_create(_ baseUrl: UnsafePointer<CChar>) -> UnsafeMutableRawPointer?

@_silgen_name("waas_client_get_v3_wallet")
private func waas_client_get_v3_wallet(_ client: UnsafeMutableRawPointer?, _ accessToken: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_get_v3_wallet_key")
private func waas_client_get_v3_wallet_key(_ client: UnsafeMutableRawPointer?, _ accessToken: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_get_v3_wallet_user")
private func waas_client_get_v3_wallet_user(_ client: UnsafeMutableRawPointer?, _ accessToken: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_get_v3_wallet_token")
private func waas_client_get_v3_wallet_token(_ client: UnsafeMutableRawPointer?, _ accessToken: UnsafePointer<CChar>, _ id: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v3_wallet_key")
private func waas_client_post_v3_wallet_key(_ client: UnsafeMutableRawPointer?, _ accessToken: UnsafePointer<CChar>, _ id: UnsafePointer<CChar>, _ curve: UnsafePointer<CChar>, _ publicKey: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_solana_wallet_account_info")
private func waas_client_post_v2_solana_wallet_account_info(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ address: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_solana_wallet_balance")
private func waas_client_post_v2_solana_wallet_balance(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ address: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_solana_tx_generate_transfer_sol")
private func waas_client_post_v2_solana_tx_generate_transfer_sol(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ fromAddress: UnsafePointer<CChar>,
    _ toAddress: UnsafePointer<CChar>,
    _ feePayerAddress: UnsafePointer<CChar>,
    _ amount: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_solana_tx_send_transaction")
private func waas_client_post_v2_solana_tx_send_transaction(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ serializedTx: UnsafePointer<CChar>,
    _ signatures: UnsafePointer<CChar>, // 콤마로 구분된 문자열로 전달 시
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_account")
private func waas_client_post_v2_xrp_account(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ publicKey: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

// ====== XRP FUNCTIONS ======
@_silgen_name("waas_client_post_v2_xrp_balance")
private func waas_client_post_v2_xrp_balance(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_server_info")
private func waas_client_post_v2_xrp_server_info(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_account_info")
private func waas_client_post_v2_xrp_account_info(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_transfer")
private func waas_client_post_v2_xrp_transfer(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ amount: UnsafePointer<CChar>,
    _ destination: UnsafePointer<CChar>,
    _ destinationTag: UnsafePointer<CChar>?, // NULL이면 None
    _ fee: UnsafePointer<CChar>,
    _ publicKey: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_send_transaction")
private func waas_client_post_v2_xrp_send_transaction(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ publicKey: UnsafePointer<CChar>,
    _ serializedTx: UnsafePointer<CChar>,
    _ signature: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_fee")
private func waas_client_post_v2_xrp_fee(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_transaction")
private func waas_client_post_v2_xrp_transaction(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ txHash: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_trustline")
private func waas_client_post_v2_xrp_trustline(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ currency: UnsafePointer<CChar>,
    _ fee: UnsafePointer<CChar>,
    _ issuer: UnsafePointer<CChar>,
    _ limit: UnsafePointer<CChar>,
    _ publicKey: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_trustline_status")
private func waas_client_post_v2_xrp_trustline_status(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ currency: UnsafePointer<CChar>,
    _ issuer: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_ft_balance")
private func waas_client_post_v2_xrp_ft_balance(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ issuer: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_ft_transfer_estimate")
private func waas_client_post_v2_xrp_ft_transfer_estimate(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ amount: UnsafePointer<CChar>,
    _ currency: UnsafePointer<CChar>,
    _ destination: UnsafePointer<CChar>,
    _ destinationTag: UnsafePointer<CChar>?, // NULL이면 None
    _ issuer: UnsafePointer<CChar>,
    _ publicKey: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_post_v2_xrp_ft_transfer")
private func waas_client_post_v2_xrp_ft_transfer(
    _ client: UnsafeMutableRawPointer?,
    _ accessToken: UnsafePointer<CChar>,
    _ account: UnsafePointer<CChar>,
    _ amount: UnsafePointer<CChar>,
    _ currency: UnsafePointer<CChar>,
    _ destination: UnsafePointer<CChar>,
    _ destinationTag: UnsafePointer<CChar>?, // NULL이면 None
    _ fee: UnsafePointer<CChar>,
    _ issuer: UnsafePointer<CChar>,
    _ publicKey: UnsafePointer<CChar>,
    _ network: UnsafePointer<CChar>
) -> UnsafeMutablePointer<CChar>?

@_silgen_name("waas_client_free")
private func waas_client_free(_ client: UnsafeMutableRawPointer?)

@_silgen_name("waas_string_free")
private func waas_string_free(_ s: UnsafeMutablePointer<CChar>?)

public class WaasClient {
    private var client: UnsafeMutableRawPointer?
    
    public init(baseUrl: String) throws {
        client = baseUrl.withCString { baseUrlPtr in
            waas_client_create(baseUrlPtr)
        }
        
        guard client != nil else {
            throw WaasError.clientInitializationFailed
        }
    }
    
    public func getV3Wallet(accessToken: String) async -> Result<WalletResponse, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        accessToken.withCString { accessTokenPtr in
            resultPtr = waas_client_get_v3_wallet(client, accessTokenPtr)
        }
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get wallet"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        // Assuming parseWaasResponse is a function to parse the response
        let result = response.parseWaasResponse(as: WalletResponse.self)
        return result
    }
    
    public func getV3WalletKey(accessToken: String) async -> Result<WalletKeyResponse, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        accessToken.withCString { accessTokenPtr in
            resultPtr = waas_client_get_v3_wallet_key(client, accessTokenPtr)
        }
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get wallet key"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        let result = response.parseWaasResponse(as: WalletKeyResponse.self)
        return result
    }
    
    public func getV3WalletUser(accessToken: String) async -> Result<WalletUserResponse, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        accessToken.withCString { accessTokenPtr in
            resultPtr = waas_client_get_v3_wallet_user(client, accessTokenPtr)
        }
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get wallet user"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        let result = response.parseWaasResponse(as: WalletUserResponse.self)
        return result
    }
    
    deinit {
        if let client = client {
            waas_client_free(client)
        }
    }

    public func getV3WalletToken(accessToken: String, id: String) async -> Result<WalletTokenResponse, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            id.withCString { idPtr in
                resultPtr = waas_client_get_v3_wallet_token(client, accessTokenPtr, idPtr)
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get wallet token"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        let result = response.parseWaasResponse(as: WalletTokenResponse.self)
        return result
    }

    public func postV3WalletKey(accessToken: String, id: String, curve: String, publicKey: String) async -> Result<WalletKey, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        accessToken.withCString { accessTokenPtr in
            id.withCString { idPtr in
                curve.withCString { curvePtr in
                    publicKey.withCString { publicKeyPtr in
                        resultPtr = waas_client_post_v3_wallet_key(client, accessTokenPtr, idPtr, curvePtr, publicKeyPtr)
                    }
                }
            }
        }   
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to post wallet key"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        let result = response.parseWaasResponse(as: WalletKey.self)
        return result
    }

    public func postV2SolanaWalletAccountInfo(accessToken: String, address: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            address.withCString { addressPtr in
                network.withCString { networkPtr in
                    resultPtr = waas_client_post_v2_solana_wallet_account_info(client, accessTokenPtr, addressPtr, networkPtr)
                }
            }
        }
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get wallet account info"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2SolanaWalletBalance(accessToken: String, address: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            address.withCString { addressPtr in
                network.withCString { networkPtr in
                    resultPtr = waas_client_post_v2_solana_wallet_balance(client, accessTokenPtr, addressPtr, networkPtr)
                }
            }
        }
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get wallet balance"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }
    
    public func postV2SolanaTxGenerateTransferSol(accessToken: String, fromAddress: String, toAddress: String, feePayerAddress: String?, amount: String, network: String) async -> Result<Data, WaasError> {
        
        let feePayerAddressValue = feePayerAddress ?? ""
        
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            fromAddress.withCString { fromAddressPtr in
                toAddress.withCString { toAddressPtr in
                    feePayerAddressValue.withCString { feePayerAddressPtr in
                        amount.withCString { amountPtr in
                            network.withCString { networkPtr in
                                resultPtr = waas_client_post_v2_solana_tx_generate_transfer_sol(client, accessTokenPtr, fromAddressPtr, toAddressPtr, feePayerAddressPtr, amountPtr, networkPtr)    
                            }
                        }
                    }
                }
            }
        }   

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to generate transfer transaction"))
        }
        
        let response = String(cString: ptr) 
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }
    
    public func postV2SolanaTxSendTransaction(accessToken: String, serializedTx: String, signatures: [String], network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            serializedTx.withCString { serializedTxPtr in
            let signaturesJoined = signatures.joined(separator: ",")
                signaturesJoined.withCString { signaturesPtr in
                    network.withCString { networkPtr in
                        resultPtr = waas_client_post_v2_solana_tx_send_transaction(client, accessTokenPtr, serializedTxPtr, signaturesPtr, networkPtr)
                    }
                }
            }
        }
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to send transaction"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpAccount(accessToken: String, publicKey: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            publicKey.withCString { publicKeyPtr in
                network.withCString { networkPtr in
                    resultPtr = waas_client_post_v2_xrp_account(client, accessTokenPtr, publicKeyPtr, networkPtr)   
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP account"))
        }   

        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpBalance(accessToken: String, account: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                network.withCString { networkPtr in
                    resultPtr = waas_client_post_v2_xrp_balance(client, accessTokenPtr, accountPtr, networkPtr)
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP balance"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpServerInfo(accessToken: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            network.withCString { networkPtr in
                resultPtr = waas_client_post_v2_xrp_server_info(client, accessTokenPtr, networkPtr)
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP server info"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpAccountInfo(accessToken: String, account: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                network.withCString { networkPtr in
                    resultPtr = waas_client_post_v2_xrp_account_info(client, accessTokenPtr, accountPtr, networkPtr)
                }   
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP account info"))
        }

        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpTransfer(accessToken: String, account: String, amount: String, destination: String, destinationTag: String?, fee: String, publicKey: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                amount.withCString { amountPtr in
                    destination.withCString { destinationPtr in 
                        fee.withCString { feePtr in
                            publicKey.withCString { publicKeyPtr in
                                network.withCString { networkPtr in
                                    if let destinationTag = destinationTag {
                                        // destinationTag가 nil이 아닌 경우
                                        destinationTag.withCString { destinationTagPtr in
                                            resultPtr = waas_client_post_v2_xrp_transfer(client, accessTokenPtr, accountPtr, amountPtr, destinationPtr, destinationTagPtr, feePtr, publicKeyPtr, networkPtr)
                                        }
                                    } else {
                                        // destinationTag가 nil인 경우
                                        resultPtr = waas_client_post_v2_xrp_transfer(client, accessTokenPtr, accountPtr, amountPtr, destinationPtr, nil, feePtr, publicKeyPtr, networkPtr)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to transfer XRP"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpSendTransaction(accessToken: String, publicKey: String, serializedTx: String, signature: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            publicKey.withCString { publicKeyPtr in
                serializedTx.withCString { serializedTxPtr in
                    signature.withCString { signaturePtr in
                        network.withCString { networkPtr in
                            resultPtr = waas_client_post_v2_xrp_send_transaction(client, accessTokenPtr, publicKeyPtr, serializedTxPtr, signaturePtr, networkPtr)
                        }
                    }
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to send XRP transaction"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpFee(accessToken: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            network.withCString { networkPtr in
                resultPtr = waas_client_post_v2_xrp_fee(client, accessTokenPtr, networkPtr)
            }
        }
        
        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP fee"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpTransaction(accessToken: String, txHash: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            txHash.withCString { txHashPtr in
                network.withCString { networkPtr in
                    resultPtr = waas_client_post_v2_xrp_transaction(client, accessTokenPtr, txHashPtr, networkPtr)
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP transaction"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpTrustline(accessToken: String, account: String, currency: String, fee: String, issuer: String, limit: String, publicKey: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                currency.withCString { currencyPtr in
                    fee.withCString { feePtr in
                        issuer.withCString { issuerPtr in
                            limit.withCString { limitPtr in
                                publicKey.withCString { publicKeyPtr in
                                    network.withCString { networkPtr in
                                        resultPtr = waas_client_post_v2_xrp_trustline(client, accessTokenPtr, accountPtr, currencyPtr, feePtr, issuerPtr, limitPtr, publicKeyPtr, networkPtr)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to create XRP trustline"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpTrustlineStatus(accessToken: String, account: String, currency: String, issuer: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                currency.withCString { currencyPtr in
                    issuer.withCString { issuerPtr in
                        network.withCString { networkPtr in
                            resultPtr = waas_client_post_v2_xrp_trustline_status(client, accessTokenPtr, accountPtr, currencyPtr, issuerPtr, networkPtr)
                        }
                    }
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP trustline status"))
        }
        
        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)   
    }

    public func postV2XrpFtBalance(accessToken: String, account: String, issuer: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                issuer.withCString { issuerPtr in
                    network.withCString { networkPtr in
                        resultPtr = waas_client_post_v2_xrp_ft_balance(client, accessTokenPtr, accountPtr, issuerPtr, networkPtr)
                    }
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP FT balance"))
        }

        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpFtTransferEstimate(accessToken: String, account: String, amount: String, currency: String, destination: String, destinationTag: String?, issuer: String, publicKey: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                amount.withCString { amountPtr in
                    currency.withCString { currencyPtr in
                        destination.withCString { destinationPtr in
                            issuer.withCString { issuerPtr in
                                publicKey.withCString { publicKeyPtr in
                                    network.withCString { networkPtr in
                                        if let destinationTag = destinationTag {
                                            // destinationTag가 nil이 아닌 경우
                                            destinationTag.withCString { destinationTagPtr in
                                                resultPtr = waas_client_post_v2_xrp_ft_transfer_estimate(client, accessTokenPtr, accountPtr, amountPtr, currencyPtr, destinationPtr, destinationTagPtr, issuerPtr, publicKeyPtr, networkPtr)
                                            }
                                        } else {
                                            // destinationTag가 nil인 경우
                                            resultPtr = waas_client_post_v2_xrp_ft_transfer_estimate(client, accessTokenPtr, accountPtr, amountPtr, currencyPtr, destinationPtr, nil, issuerPtr, publicKeyPtr, networkPtr)
                                        }
                                    }
                                }
                            }   
                        }
                    }
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to get XRP FT transfer estimate"))
        }

        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }

    public func postV2XrpFtTransfer(accessToken: String, account: String, amount: String, currency: String, destination: String, destinationTag: String?, fee: String, issuer: String, publicKey: String, network: String) async -> Result<Data, WaasError> {
        var resultPtr: UnsafeMutablePointer<CChar>?

        accessToken.withCString { accessTokenPtr in
            account.withCString { accountPtr in
                amount.withCString { amountPtr in
                    currency.withCString { currencyPtr in
                        destination.withCString { destinationPtr in
                            fee.withCString { feePtr in
                                issuer.withCString { issuerPtr in
                                    publicKey.withCString { publicKeyPtr in
                                        network.withCString { networkPtr in
                                            if let destinationTag = destinationTag {
                                                // destinationTag가 nil이 아닌 경우
                                                destinationTag.withCString { destinationTagPtr in
                                                    resultPtr = waas_client_post_v2_xrp_ft_transfer(client, accessTokenPtr, accountPtr, amountPtr, currencyPtr, destinationPtr, destinationTagPtr, feePtr, issuerPtr, publicKeyPtr, networkPtr)
                                                }
                                            } else {
                                                // destinationTag가 nil인 경우
                                                resultPtr = waas_client_post_v2_xrp_ft_transfer(client, accessTokenPtr, accountPtr, amountPtr, currencyPtr, destinationPtr, nil, feePtr, issuerPtr, publicKeyPtr, networkPtr)
                                            }
                                        }
                                    }
                                }
                            }   
                        }
                    }
                }
            }
        }

        guard let ptr = resultPtr else {
            return .failure(WaasError.operationFailed("Failed to transfer XRP FT"))
        }

        let response = String(cString: ptr)
        waas_string_free(ptr)
        if response.hasErrorType() {
            return .failure(WaasError.operationFailed(response))
        }
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }
}
