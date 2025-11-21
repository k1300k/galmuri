# Galmuri Diary API 사용 가이드

## API 기본 정보

**Base URL**: `https://your-app.onrender.com` (Render 배포 시)
또는 `http://localhost:8000` (로컬 개발 시)

**인증**: `X-API-Key` 헤더 필요

## 1. Chrome Extension에서 사용

### 설정 방법

1. **Extension 아이콘 클릭**
2. **"설정" 탭** 선택
3. 다음 정보 입력:
   - **API URL**: `https://your-app.onrender.com`
   - **API Key**: `test_api_key_1234567890` (또는 설정한 키)
   - **User ID**: UUID 형식 (예: `550e8400-e29b-41d4-a716-446655440000`)
4. **"설정 저장"** 클릭

### 사용 방법

1. **웹 페이지 캡처**
   - 저장하고 싶은 웹 페이지로 이동
   - Extension 아이콘 클릭
   - 자동으로 현재 페이지 캡처
   - 메모 입력 (선택사항)
   - **"저장"** 클릭

2. **자동 처리**
   - Extension이 자동으로 API 호출
   - 로컬에 먼저 저장 (Local First)
   - 서버와 동기화

### Extension 코드에서의 사용

Extension은 `popup.js`에서 자동으로 API를 호출합니다:

```javascript
// popup.js에서 자동 실행
const response = await fetch(`${apiUrl}/api/capture`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey
  },
  body: JSON.stringify({
    user_id: userId,
    image_data: screenshot,
    source_url: currentUrl,
    page_title: currentTitle,
    memo_content: memo,
    platform: 'WEB_EXTENSION'
  })
});
```

---

## 2. Android App에서 사용

### 설정 방법

1. **앱 실행**
2. **설정 화면**으로 이동
3. 다음 정보 입력:
   - **API URL**: `https://your-app.onrender.com`
   - **API Key**: `test_api_key_1234567890`
   - **User ID**: UUID 형식
4. **"설정 저장"** 클릭

### 사용 방법

1. **이미지 캡처**
   - 하단 **"캡처"** 버튼 클릭
   - 갤러리에서 선택 또는 카메라로 촬영
   - 제목 입력
   - 메모 입력 (선택사항)
   - **저장** 클릭

2. **저장된 항목 보기**
   - 홈 화면에서 목록 확인
   - 검색 기능 사용

### 앱 코드에서의 사용

Flutter 앱은 `galmuri_api_client.dart`에서 API를 호출합니다:

```dart
// 자동으로 API 호출
final apiClient = GalmuriApiClient(
  baseUrl: 'https://your-app.onrender.com',
  apiKey: 'your_api_key'
);

final item = await apiClient.capture(request);
```

---

## 3. 직접 API 호출 (curl, Postman 등)

### 기본 헤더

모든 API 요청에 다음 헤더가 필요합니다:

```bash
X-API-Key: test_api_key_1234567890
Content-Type: application/json
```

### API 엔드포인트 사용 예시

#### 1. Health Check

```bash
curl https://your-app.onrender.com/
```

**응답:**
```json
{
  "service": "Galmuri Diary API",
  "version": "1.0.0",
  "status": "running"
}
```

#### 2. 캡처 및 저장

```bash
curl -X POST https://your-app.onrender.com/api/capture \
  -H "X-API-Key: test_api_key_1234567890" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "image_data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==",
    "source_url": "https://example.com",
    "page_title": "Example Page",
    "memo_content": "테스트 메모",
    "platform": "WEB_EXTENSION"
  }'
```

**응답:**
```json
{
  "id": "dcd1b75e-9d57-4535-8fcf-777824a12e7c",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "source_url": "https://example.com",
  "page_title": "Example Page",
  "memo_content": "테스트 메모",
  "ocr_text": "",
  "ocr_status": "PENDING",
  "platform": "WEB_EXTENSION",
  "is_synced": true,
  "created_at": "2025-11-22T05:00:00",
  "updated_at": "2025-11-22T05:00:00"
}
```

#### 3. 아이템 목록 조회

```bash
curl -H "X-API-Key: test_api_key_1234567890" \
  https://your-app.onrender.com/api/items/550e8400-e29b-41d4-a716-446655440000
```

**응답:**
```json
[
  {
    "id": "dcd1b75e-9d57-4535-8fcf-777824a12e7c",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "page_title": "Example Page",
    "memo_content": "테스트 메모",
    "ocr_text": "추출된 텍스트",
    "ocr_status": "DONE",
    "created_at": "2025-11-22T05:00:00"
  }
]
```

#### 4. 검색

```bash
curl -X POST https://your-app.onrender.com/api/search \
  -H "X-API-Key: test_api_key_1234567890" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "query": "예시"
  }'
```

**검색 범위:**
- 제목 (`page_title`)
- 메모 (`memo_content`)
- OCR 텍스트 (`ocr_text`)

#### 5. 단일 아이템 조회

```bash
curl -H "X-API-Key: test_api_key_1234567890" \
  https://your-app.onrender.com/api/item/dcd1b75e-9d57-4535-8fcf-777824a12e7c
```

#### 6. 아이템 삭제

```bash
curl -X DELETE \
  -H "X-API-Key: test_api_key_1234567890" \
  https://your-app.onrender.com/api/item/dcd1b75e-9d57-4535-8fcf-777824a12e7c
```

#### 7. 미동기화 항목 조회

```bash
curl -H "X-API-Key: test_api_key_1234567890" \
  https://your-app.onrender.com/api/items/550e8400-e29b-41d4-a716-446655440000/unsynced
```

---

## 4. Postman에서 사용

### Collection 설정

1. **Postman 열기**
2. **New Collection** 생성: "Galmuri Diary API"
3. **Variables 설정**:
   - `base_url`: `https://your-app.onrender.com`
   - `api_key`: `test_api_key_1234567890`
   - `user_id`: `550e8400-e29b-41d4-a716-446655440000`

### 요청 예시

**1. Health Check**
- Method: `GET`
- URL: `{{base_url}}/`
- Headers: 없음

**2. Capture**
- Method: `POST`
- URL: `{{base_url}}/api/capture`
- Headers:
  - `X-API-Key`: `{{api_key}}`
  - `Content-Type`: `application/json`
- Body (JSON):
```json
{
  "user_id": "{{user_id}}",
  "image_data": "base64_encoded_image",
  "page_title": "Test Page",
  "platform": "WEB_EXTENSION"
}
```

---

## 5. Python에서 사용

### requests 라이브러리 사용

```python
import requests
import base64

# API 설정
BASE_URL = "https://your-app.onrender.com"
API_KEY = "test_api_key_1234567890"
USER_ID = "550e8400-e29b-41d4-a716-446655440000"

headers = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}

# 1. Health Check
response = requests.get(f"{BASE_URL}/")
print(response.json())

# 2. 이미지 캡처
with open("screenshot.png", "rb") as f:
    image_data = base64.b64encode(f.read()).decode()

payload = {
    "user_id": USER_ID,
    "image_data": image_data,
    "page_title": "Python Test",
    "platform": "WEB_EXTENSION"
}

response = requests.post(
    f"{BASE_URL}/api/capture",
    headers=headers,
    json=payload
)
print(response.json())

# 3. 아이템 조회
response = requests.get(
    f"{BASE_URL}/api/items/{USER_ID}",
    headers=headers
)
items = response.json()
print(f"총 {len(items)}개 항목")

# 4. 검색
payload = {
    "user_id": USER_ID,
    "query": "검색어"
}
response = requests.post(
    f"{BASE_URL}/api/search",
    headers=headers,
    json=payload
)
results = response.json()
print(f"검색 결과: {len(results)}개")
```

---

## 6. JavaScript/TypeScript에서 사용

### fetch API 사용

```javascript
const BASE_URL = 'https://your-app.onrender.com';
const API_KEY = 'test_api_key_1234567890';
const USER_ID = '550e8400-e29b-41d4-a716-446655440000';

// 헬퍼 함수
async function apiCall(endpoint, method = 'GET', body = null) {
  const options = {
    method,
    headers: {
      'X-API-Key': API_KEY,
      'Content-Type': 'application/json'
    }
  };
  
  if (body) {
    options.body = JSON.stringify(body);
  }
  
  const response = await fetch(`${BASE_URL}${endpoint}`, options);
  return await response.json();
}

// 1. Health Check
const health = await apiCall('/');
console.log(health);

// 2. 캡처
const capture = await apiCall('/api/capture', 'POST', {
  user_id: USER_ID,
  image_data: 'base64_encoded_image',
  page_title: 'JavaScript Test',
  platform: 'WEB_EXTENSION'
});
console.log(capture);

// 3. 아이템 조회
const items = await apiCall(`/api/items/${USER_ID}`);
console.log(items);

// 4. 검색
const search = await apiCall('/api/search', 'POST', {
  user_id: USER_ID,
  query: '검색어'
});
console.log(search);
```

---

## 7. 실제 사용 시나리오

### 시나리오 1: 웹 페이지 저장

1. **Chrome Extension 사용**
   - 웹 페이지 방문
   - Extension 클릭
   - 자동 캡처 및 저장

### 시나리오 2: 모바일 스크린샷 저장

1. **Android App 사용**
   - 앱 실행
   - 캡처 버튼
   - 이미지 선택/촬영
   - 저장

### 시나리오 3: 프로그래밍으로 자동 저장

```python
# Python 스크립트로 자동 캡처
import requests
from selenium import webdriver
from PIL import Image

# 웹 페이지 스크린샷
driver = webdriver.Chrome()
driver.get("https://example.com")
driver.save_screenshot("screenshot.png")

# API로 저장
# ... (위의 Python 예시 코드 사용)
```

---

## 8. API 응답 코드

| 코드 | 의미 |
|------|------|
| 200 | 성공 |
| 401 | 인증 실패 (API Key 오류) |
| 404 | 리소스 없음 |
| 422 | 요청 데이터 오류 |
| 500 | 서버 오류 |

---

## 9. 이미지 데이터 형식

### Base64 인코딩

이미지를 Base64로 인코딩하여 전송:

**Python:**
```python
import base64

with open("image.png", "rb") as f:
    image_data = base64.b64encode(f.read()).decode()
```

**JavaScript:**
```javascript
// FileReader 사용
const reader = new FileReader();
reader.onload = (e) => {
  const base64 = e.target.result.split(',')[1]; // data:image/png;base64, 제거
};
reader.readAsDataURL(file);
```

---

## 10. 문제 해결

### "401 Unauthorized"
- API Key 확인
- `X-API-Key` 헤더 확인

### "422 Validation Error"
- 요청 데이터 형식 확인
- 필수 필드 확인 (`user_id`, `image_data`, `page_title`)

### "Connection timeout"
- Render Sleep Mode 확인 (무료 플랜)
- 첫 요청 시 30초 대기 가능

### "Database connection failed"
- `DATABASE_URL` 환경 변수 확인
- PostgreSQL 서비스 상태 확인

---

## 11. API 문서

**Swagger UI**: `https://your-app.onrender.com/docs`
- 모든 엔드포인트 확인
- 직접 테스트 가능
- 요청/응답 예시

**ReDoc**: `https://your-app.onrender.com/redoc`
- 더 읽기 쉬운 문서

---

## 12. 빠른 시작 체크리스트

- [ ] Render URL 확인: `https://your-app.onrender.com`
- [ ] API Key 준비
- [ ] User ID 생성 (UUID)
- [ ] Chrome Extension 설정
- [ ] 또는 Android App 설정
- [ ] 첫 캡처 테스트
- [ ] API 문서 확인 (`/docs`)

---

## 참고

- **Local First**: Extension/App은 로컬에 먼저 저장 후 서버 동기화
- **OCR 처리**: 백그라운드에서 비동기 처리 (처음에는 `PENDING`, 나중에 `DONE`)
- **검색**: 제목, 메모, OCR 텍스트 모두 검색 가능

