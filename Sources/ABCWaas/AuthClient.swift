import Foundation
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin
#else
import Glibc
#endif

@_silgen_name("auth_client_create")
private func auth_client_create(_ baseUrl: UnsafePointer<CChar>,
                              _ platform: UnsafePointer<CChar>,
                              _ accessKey: UnsafePointer<CChar>,
                              _ accessSecret: UnsafePointer<CChar>,
                              _ serviceId: UnsafePointer<CChar>) -> UnsafeMutableRawPointer?

@_silgen_name("auth_client_send_login_code")
private func auth_client_send_login_code(_ client: UnsafeMutableRawPointer?,
                                       _ email: UnsafePointer<CChar>,
                                       _ lang: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("auth_client_verify_login_code")
private func auth_client_verify_login_code(_ client: UnsafeMutableRawPointer?,
                                         _ email: UnsafePointer<CChar>,
                                         _ code: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("auth_client_login")
private func auth_client_login(_ client: UnsafeMutableRawPointer?,
                             _ grantType: UnsafePointer<CChar>,
                             _ email: UnsafePointer<CChar>,
                             _ password: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar>?

@_silgen_name("auth_client_free")
private func auth_client_free(_ client: UnsafeMutableRawPointer?)

@_silgen_name("auth_string_free")
private func auth_string_free(_ s: UnsafeMutablePointer<CChar>?)

public class AuthClient {
    private var client: UnsafeMutableRawPointer?
    
    public init(baseUrl: String, accessKey: String, accessSecret: String, serviceId: String) throws {
        let platform = "ios" // iOS에서는 항상 "ios"
        
        client = baseUrl.withCString { baseUrlPtr in
            platform.withCString { platformPtr in
                accessKey.withCString { accessKeyPtr in
                    accessSecret.withCString { accessSecretPtr in
                        serviceId.withCString { serviceIdPtr in
                            auth_client_create(
                                baseUrlPtr,
                                platformPtr,
                                accessKeyPtr,
                                accessSecretPtr,
                                serviceIdPtr
                            )
                        }
                    }
                }
            }
        }
        
        guard client != nil else {
            throw AuthError.clientInitializationFailed
        }
    }
    
    public func sendLoginCode(
        email: String,
        lang: String
    ) async -> Result<AuthResponse<EmptyResponse>, AuthError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        email.withCString { emailPtr in
            lang.withCString { langPtr in
                resultPtr = auth_client_send_login_code(
                    client,
                    emailPtr,
                    langPtr
                )
            }
        }
        
        guard let ptr = resultPtr else {
            return .failure( AuthError.operationFailed("Failed to send login code"))
        }
        
        let response = String(cString: ptr)
        auth_string_free(ptr)
        let result = response.parseAuthResponse(as: EmptyResponse.self)
        return result
    }
    
    public func verifyLoginCode(
        email: String,
        code: String
    ) async -> Result<AuthResponse<EmptyResponse>, AuthError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        email.withCString { emailPtr in
            code.withCString { codePtr in
                resultPtr = auth_client_verify_login_code(
                    client,
                    emailPtr,
                    codePtr
                )
            }
        }
        
        guard let ptr = resultPtr else {
            return .failure(AuthError.operationFailed("Failed to verify login code"))
        }
        
        let response = String(cString: ptr)
        auth_string_free(ptr)
        let result = response.parseAuthResponse(as: EmptyResponse.self)

        return result
    }
    
    public func login(
        grantType: String,
        email: String,
        password: String
    ) async -> Result<AuthResponse<LoginResponse>, AuthError> {
        var resultPtr: UnsafeMutablePointer<CChar>?
        
        grantType.withCString { grantTypePtr in
            email.withCString { emailPtr in
                password.withCString { passwordPtr in
                    resultPtr = auth_client_login(
                        client,
                        grantTypePtr,
                        emailPtr,
                        passwordPtr
                    )
                }
            }
        }
        
        guard let ptr = resultPtr else {
            return .failure(AuthError.operationFailed("Failed to login"))
        }
        
        let response = String(cString: ptr)
        auth_string_free(ptr)
        let result = response.parseAuthResponse(as: LoginResponse.self)

        return result
    }
    
    deinit {
        if let client = client {
            auth_client_free(client)
        }
    }
} 
