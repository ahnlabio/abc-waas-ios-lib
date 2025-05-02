# abc-waas-ios-lib

# WaasHelper 사용 가이드

## 개요
`WaasHelper`는 WAAS(Wallet as a Service)와 MPC(Multi-Party Computation) 기능을 쉽게 사용할 수 있도록 도와주는 헬퍼 클래스입니다.

## 설치 방법

### iOS (Swift)
```
package dependencies
https://github.com/ahnlabio/abc-waas-ios-lib 추가
```

## 초기화

### iOS (Swift)
```swift
let waasClient = WaasClient("https://waas.example.com")
let node1BaseURL = "https://node1.example.com"
let node2BaseURL = "https://node2.example.com"

let waasHelper = WaasHelper(
    waasClient: waasClient,
    node1BaseURL: node1BaseURL,
    node2BaseURL: node2BaseURL
)
```

## 주요 기능

### 1. 키 쉐어 생성 (generateKeyShare)
새로운 키 쉐어를 생성합니다.

```swift
// Swift
let result = await waasHelper.generateKeyShare(
    accessToken: "your_access_token",
    curve: "secp256k1",
    password: "your_password"
)

switch result {
case .success(let response):
    print("Key share generated: \(response)")
case .failure(let error):
    print("Error: \(error.description)")
}
```

### 2. 키 쉐어 복구 (recoverKeyShare)
기존 키 쉐어를 복구합니다.

```swift
// Swift
let result = await waasHelper.recoverKeyShare(
    accessToken: "your_access_token",
    curve: "secp256k1",
    password: "your_password"
)

switch result {
case .success(let response):
    print("Key share recovered: \(response)")
case .failure(let error):
    print("Error: \(error.description)")
}
```

### 3. 메시지 서명 (sign)
메시지에 대한 서명을 생성합니다.

```swift
// Swift
let result = await waasHelper.sign(
    accessToken: "your_access_token",
    keyId: "your_key_id",
    encryptedShare: "your_encrypted_share",
    secretStore: "your_secret_store",
    curve: "secp256k1",
    message: "your_message"
)

switch result {
case .success(let response):
    print("Message signed: \(response)")
case .failure(let error):
    print("Error: \(error.description)")
}
```

### 4. 비밀번호 검증 (validatePassword)
비밀번호와 시크릿 스토어의 유효성을 검증합니다.

```swift
// Swift
let result = await waasHelper.validatePassword(
    password: "your_password",
    secretStore: "your_secret_store"
)

switch result {
case .success(let response):
    print("Password validated: \(response)")
case .failure(let error):
    print("Error: \(error.description)")
}
```

### 5. 쉐어 검증 (validateShare)
쉐어와 시크릿 스토어의 유효성을 검증합니다.

```swift
// Swift
let result = await waasHelper.validateShare(
    encryptedShare: "your_encrypted_share",
    secretStore: "your_secret_store"
)

switch result {
case .success(let response):
    print("Share validated: \(response)")
case .failure(let error):
    print("Error: \(error.description)")
}
```

## 응답 타입 설명

### GenerateShareResponse
키 쉐어 생성 응답 타입입니다.
```swift
// Swift
struct GenerateShareResponse {
    let keyId: String          // 생성된 키의 고유 식별자
    let encryptedShare: String // 암호화된 키 쉐어
    let secretStore: String    // 시크릿 스토어 정보
    let curve: String          // 사용된 곡선 타입 (예: secp256k1)
}
```

### RecoverShareResponse
키 쉐어 복구 응답 타입입니다.
```swift
// Swift
struct RecoverShareResponse {
    let keyId: String          // 복구된 키의 고유 식별자
    let encryptedShare: String // 암호화된 키 쉐어
    let secretStore: String    // 시크릿 스토어 정보
    let curve: String          // 사용된 곡선 타입 (예: secp256k1)
}
```

### SignResponse
메시지 서명 응답 타입입니다.
```swift
// Swift
struct SignResponse {
    let signature: String      // 생성된 서명
    let publicKey: String      // 공개키
    let curve: String          // 사용된 곡선 타입 (예: secp256k1)
}
```

### ValidatePasswordAndSecretStoreResponse
비밀번호 검증 응답 타입입니다.
```swift
// Swift
struct ValidatePasswordAndSecretStoreResponse {
    let isValid: Bool          // 비밀번호 유효성 검증 결과
    let message: String        // 검증 결과 메시지
}
```

### ValidateShareAndSecretStoreResponse
쉐어 검증 응답 타입입니다.
```swift
// Swift
struct ValidateShareAndSecretStoreResponse {
    let isValid: Bool          // 쉐어 유효성 검증 결과
    let message: String        // 검증 결과 메시지
}
```

## 에러 처리

`WaasHelper`는 다음과 같은 에러 타입을 제공합니다:

1. `WaasError`: WAAS 관련 에러
2. `MpcError`: MPC 관련 에러
3. `UnknownError`: 알 수 없는 에러

각 에러는 `description` (Swift) 또는 `message` (Kotlin) 프로퍼티를 통해 상세한 에러 메시지를 제공합니다.

## 주의사항

1. 모든 메서드는 비동기로 동작하며, 적절한 비동기 처리 방식을 사용해야 합니다.
2. iOS에서는 `async/await`를, Android에서는 코루틴을 사용합니다.
3. 에러 처리를 항상 포함하여 안정적인 애플리케이션을 구현해야 합니다.
4. 민감한 정보(비밀번호, 토큰 등)는 안전하게 관리해야 합니다. 
