//
//  LoginResponse.swift
//  web3
//
//  Created by theo-2022 on 3/26/25.
//
import Foundation

public struct EmptyResponse: Decodable{}

// 기본 응답 구조체 정의 (제네릭 타입 T를 사용)
public struct AuthResponse<T: Decodable>: Decodable {
    public let code: Int
    public let msg: String
    public let data: T?
    
    public init(code: Int, msg: String, data: T?) {
        self.code = code
        self.msg = msg
        self.data = data
    }
    
    public var isSuccess: Bool {
            return code == 0
    }
}

// MARK: - JSON 응답을 위한 디코딩 모델
public struct LoginResponse: Codable {
    public let accessToken: String?
    public let tokenType: String?
    public let expireIn: Int?
    public let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expireIn = "expire_in"
        case refreshToken = "refresh_token"
    }
}

