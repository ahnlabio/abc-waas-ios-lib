//
//  AuthResponseParser.swift
//  web3
//
//  Created by theo-2022 on 3/26/25.
//

import Foundation


// 파싱 관련 오류 정의
public enum AuthError: Error {
    case invalidJsonFormat
    case noData
    case decodingError(Error)
    case clientInitializationFailed
    case operationFailed(String)
    
    public var description: String {
        switch self {
        case .invalidJsonFormat:
            return "JSON 형식이 유효하지 않습니다."
        case .noData:
            return "응답에 데이터가 없습니다."
        case .decodingError(let error):
            return "디코딩 오류: \(error.localizedDescription)"
        case .clientInitializationFailed:
            return "클라이언트 초기化에 실패했습니다."
        case .operationFailed(let message):
            return "연산에 실패했습니다: \(message)"
        }
    }
}

// 응답 파싱을 위한 클래스
public class AuthResponseParser {
    
    // 싱글톤 인스턴스
    public static let shared = AuthResponseParser()
    
    private init() {}
    
    // JSON 문자열을 특정 타입의 AuthResponse로 파싱
    public func parse<T: Decodable>(jsonString: String, type: T.Type) -> Result<AuthResponse<T>, AuthError> {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return .failure(.invalidJsonFormat)
        }
        
        return parse(jsonData: jsonData, type: type)
    }
    
    // JSON 데이터를 특정 타입의 AuthResponse로 파싱
    public func parse<T: Decodable>(jsonData: Data, type: T.Type) -> Result<AuthResponse<T>, AuthError> {
        do {
            let decoder = JSONDecoder()
            // 스네이크 케이스를 카멜 케이스로 변환 (필요시 주석 해제)
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let response = try decoder.decode(AuthResponse<T>.self, from: jsonData)
            return .success(response)
        } catch {
            return .failure(.decodingError(error))
        }
    }
    
    // AuthResponse에서 데이터만 추출 (데이터가 없거나 코드가 정상이 아닌 경우 오류 반환)
    public func extractData<T: Decodable>(from jsonString: String, type: T.Type, successCode: Int = 0) -> Result<T, AuthError> {
        let result = parse(jsonString: jsonString, type: type)
        
        switch result {
        case .success(let response):
            // 코드 검증 (기본 성공 코드 0)
            guard response.code == successCode else {
                return .failure(.noData)
            }
            
            guard let data = response.data else {
                return .failure(.noData)
            }
            
            return .success(data)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// 편의를 위한 String 확장
extension String {
    public func parseAuthResponse<T: Decodable>(as type: T.Type) -> Result<AuthResponse<T>, AuthError> {
        return AuthResponseParser.shared.parse(jsonString: self, type: type)
    }
    
    public func extractAuthData<T: Decodable>(as type: T.Type, successCode: Int = 0) -> Result<T, AuthError> {
        return AuthResponseParser.shared.extractData(from: self, type: type, successCode: successCode)
    }
}
