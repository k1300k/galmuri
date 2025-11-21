# API 사용 예제

이 폴더에는 Galmuri Diary API를 사용하는 예제 코드가 있습니다.

## 파일 목록

- `api_test.py` - Python 예제
- `api_test.js` - JavaScript/Node.js 예제

## 사용 방법

### Python 예제

```bash
# 의존성 설치
pip install requests

# 설정 수정
# api_test.py 파일에서 BASE_URL과 API_KEY 수정

# 실행
python examples/api_test.py
```

### JavaScript 예제

```bash
# Node.js 환경
npm install node-fetch

# 설정 수정
# api_test.js 파일에서 BASE_URL과 API_KEY 수정

# 실행
node examples/api_test.js
```

또는 브라우저 콘솔에서 직접 실행 가능합니다.

## 설정

각 파일의 상단에서 다음을 수정하세요:

```python
# Python
BASE_URL = "https://your-app.onrender.com"
API_KEY = "test_api_key_1234567890"
USER_ID = "550e8400-e29b-41d4-a716-446655440000"
```

```javascript
// JavaScript
const BASE_URL = 'https://your-app.onrender.com';
const API_KEY = 'test_api_key_1234567890';
const USER_ID = '550e8400-e29b-41d4-a716-446655440000';
```

## 테스트 항목

예제 코드는 다음을 테스트합니다:

1. ✅ Health Check
2. ✅ 캡처 및 저장
3. ✅ 아이템 목록 조회
4. ✅ 단일 아이템 조회
5. ✅ 검색

