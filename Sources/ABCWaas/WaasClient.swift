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
        guard let data = response.data(using: .utf8) else {
            return .failure(WaasError.operationFailed("Invalid response encoding"))
        }
        return .success(data)
    }
}

