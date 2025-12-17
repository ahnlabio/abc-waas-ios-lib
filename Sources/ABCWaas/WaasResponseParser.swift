import Foundation

// 파싱 관련 오류 정의
public enum WaasError: Error {
    case invalidJsonFormat
    case noData
    case decodingError(Error, jsonString: String = "")
    case clientInitializationFailed
    case operationFailed(String)
    case keyNotFound(String)
    case arrayIndexOutOfBounds(Int)
    
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
        case .keyNotFound(let key):
            return "Key not found: \(key)"
        case .arrayIndexOutOfBounds(let index):
            return "Array index out of bounds: \(index)"
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
    // private struct ErrorResponse: Codable {
    //     let errorType: String
    //     let function: String
    //     let code: Int
    //     let msg: String
    //     let data: String?
    // }
    
    // JSON 문자열에서 특정 경로의 값을 추출 (깊이와 배열 인덱스 지원)
    public func extractValue<T>(from jsonString: String, path: String) -> Result<T, WaasError> {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return .failure(.invalidJsonFormat)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            let pathComponents = parsePath(path)
            var current: Any = json
            
            for component in pathComponents {
                switch component {
                case .key(let key):
                    if let dictionary = current as? [String: Any] {
                        if let value = dictionary[key] {
                            current = value
                        } else {
                            return .failure(.keyNotFound(key))
                        }
                    } else {
                        return .failure(.invalidJsonFormat)
                    }
                    
                case .index(let index):
                    if let array = current as? [Any] {
                        if index >= 0 && index < array.count {
                            current = array[index]
                        } else {
                            return .failure(.arrayIndexOutOfBounds(index))
                        }
                    } else {
                        return .failure(.invalidJsonFormat)
                    }
                }
            }
            
            // 타입 캐스팅
            if let typedValue = current as? T {
                return .success(typedValue)
            } else {
                return .failure(.operationFailed("Value cannot be cast to type \(T.self)"))
            }
        } catch {
            return .failure(.decodingError(error, jsonString: jsonString))
        }
    }
    
    // 경로 파싱을 위한 내부 구조체
    private enum PathComponent {
        case key(String)
        case index(Int)
    }
    
    // 경로 문자열을 파싱하여 키와 배열 인덱스를 분리
    private func parsePath(_ path: String) -> [PathComponent] {
        var components: [PathComponent] = []
        let parts = path.components(separatedBy: ".")
        
        for part in parts {
            // 배열 인덱스 패턴 확인 (예: "accounts[0]", "items[1]")
            if let range = part.range(of: #"\[(\d+)\]$"#, options: .regularExpression) {
                let keyPart = String(part[..<range.lowerBound])
                let indexPart = String(part[range])
                
                // 인덱스 추출
                let indexString = indexPart.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                if let index = Int(indexString) {
                    if !keyPart.isEmpty {
                        components.append(.key(keyPart))
                    }
                    components.append(.index(index))
                } else {
                    components.append(.key(part))
                }
            } else {
                components.append(.key(part))
            }
        }
        
        return components
    }
    
    // JSON 문자열에 error_type 키가 있는지 확인
    public func hasErrorType(in jsonString: String) -> Bool {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return false
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return hasErrorTypeKey(in: json)
        } catch {
            return false
        }
    }
    
    // 재귀적으로 error_type 키를 찾는 내부 함수
    private func hasErrorTypeKey(in value: Any) -> Bool {
        switch value {
        case let dictionary as [String: Any]:
            // error_type 키가 있으면 true
            if dictionary["error_type"] != nil {
                return true
            }
            
            // 하위 객체들도 검사
            for (_, value) in dictionary {
                if hasErrorTypeKey(in: value) {
                    return true
                }
            }
            
        case let array as [Any]:
            // 배열의 각 요소 검사
            for element in array {
                if hasErrorTypeKey(in: element) {
                    return true
                }
            }
            
        default:
            break
        }
        
        return false
    }
}

// 편의를 위한 String 확장
extension String {
    public func parseWaasResponse<T: Decodable>(as type: T.Type) -> Result<T, WaasError> {
        return WaasResponseParser.shared.parse(jsonString: self, type: type)
    }
    
    // JSON 문자열에서 특정 경로의 값을 추출 (타입 지정)
    public func extractValue<T>(path: String) -> Result<T, WaasError> {
        return WaasResponseParser.shared.extractValue(from: self, path: path)
    }
    
    // JSON 문자열에 error_type 키가 있는지 확인하여 에러 여부를 판단
    public func hasErrorType() -> Bool {
        return WaasResponseParser.shared.hasErrorType(in: self)
    }
}

// 편의를 위한 Data 확장
extension Data {

    public func parseWaasResponse<T: Decodable>(as type: T.Type) -> Result<T, WaasError> {
        return WaasResponseParser.shared.parse(jsonData: self, type: type)
    }
    
    // Data를 String으로 변환하고 extractValue 호출
    public func extractValue<T>(path: String) -> Result<T, WaasError> {
        guard let jsonString = String(data: self, encoding: .utf8) else {
            return .failure(.invalidJsonFormat)
        }
        return jsonString.extractValue(path: path)
    }
    
    // Data를 String으로 변환하고 hasErrorType 호출
    public func hasErrorType() -> Bool {
        guard let jsonString = String(data: self, encoding: .utf8) else {
            return false
        }
        return jsonString.hasErrorType()
    }
} 
