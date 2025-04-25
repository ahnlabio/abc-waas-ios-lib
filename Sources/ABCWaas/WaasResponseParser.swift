import Foundation

// 파싱 관련 오류 정의
public enum WaasError: Error {
    case invalidJsonFormat
    case noData
    case decodingError(Error, jsonString: String = "")
    case clientInitializationFailed
    case operationFailed(String)
    
    public var description: String {
        switch self {
        case .invalidJsonFormat:
            return "Invalid JSON format."
        case .noData:
            return "No data in response."
        case .decodingError(let error, let jsonString):
            return "Decoding error: \(error.localizedDescription)\nJSON data: \(jsonString)"
        case .clientInitializationFailed:
            return "Failed to initialize WAAS client."
        case .operationFailed(let message):
            return "WAAS operation failed: \(message)"
        }
    }
}

// 응답 파싱을 위한 클래스
public class WaasResponseParser {
    
    // 싱글톤 인스턴스
    public static let shared = WaasResponseParser()
    
    private init() {}
    
    // JSON 문자열을 특정 타입으로 파싱
    public func parse<T: Decodable>(jsonString: String, type: T.Type) -> Result<T, WaasError> {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return .failure(.invalidJsonFormat)
        }
        
        return parse(jsonData: jsonData, type: type)
    }
    
    // JSON 데이터를 특정 타입으로 파싱
    public func parse<T: Decodable>(jsonData: Data, type: T.Type) -> Result<T, WaasError> {
        do {
            let decoder = JSONDecoder()
            // 스네이크 케이스를 카멜 케이스로 변환
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let response = try decoder.decode(T.self, from: jsonData)
            return .success(response)
        } catch {
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "Unable to convert data to string"
            return .failure(.decodingError(error, jsonString: jsonString))
        }
    }
    
    // 에러 응답 처리를 위한 구조체
    private struct ErrorResponse: Codable {
        let code: Int
        let msg: String
        let data: String?
    }
}

// 편의를 위한 String 확장
extension String {
    public func parseWaasResponse<T: Decodable>(as type: T.Type) -> Result<T, WaasError> {
        return WaasResponseParser.shared.parse(jsonString: self, type: type)
    }
} 
