# Render 배포 성공 확인 가이드

## ✅ 배포 성공 확인

다음 응답이 나오면 **정상적으로 배포되었습니다!**

```json
{
  "service": "Galmuri Diary API",
  "version": "1.0.0",
  "status": "running"
}
```

## 확인 방법

### 1. Health Check (현재 확인한 것)

**URL**: `https://your-app.onrender.com/`

**응답**: 위의 JSON 응답

**의미**: 서버가 정상적으로 실행 중

### 2. API 문서 확인

**Swagger UI**: `https://your-app.onrender.com/docs`

- 모든 API 엔드포인트 확인
- 직접 테스트 가능
- 요청/응답 형식 확인

**ReDoc**: `https://your-app.onrender.com/redoc`

- 더 읽기 쉬운 API 문서
- 엔드포인트 상세 설명

### 3. API 테스트

#### 캡처 테스트

```bash
curl -X POST https://your-app.onrender.com/api/capture \
  -H "X-API-Key: test_api_key_1234567890" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "image_data": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==",
    "page_title": "Test Page",
    "platform": "WEB_EXTENSION"
  }'
```

#### 아이템 조회 테스트

```bash
curl -H "X-API-Key: test_api_key_1234567890" \
  https://your-app.onrender.com/api/items/YOUR_USER_ID
```

## 다음 단계

### 1. Chrome Extension 설정

1. Extension 아이콘 클릭
2. 설정 탭
3. API URL을 Render URL로 변경:
   - `https://your-app.onrender.com`
4. API Key 입력
5. User ID 입력
6. 저장

### 2. Android App 설정

1. 앱 실행
2. 설정 화면
3. API URL: `https://your-app.onrender.com`
4. API Key 입력
5. User ID 입력
6. 저장

### 3. 데이터베이스 확인

PostgreSQL이 제대로 연결되었는지 확인:

1. Render → PostgreSQL 서비스
2. "Connect" 탭
3. psql 명령어로 연결 테스트

또는 API를 통해 데이터 저장 후 확인

## 문제 해결

### "Connection refused" 또는 타임아웃

- Sleep Mode 확인 (무료 플랜)
- 첫 요청 시 약 30초 지연 가능
- 두 번째 요청부터 정상 속도

### "Database connection failed"

- `DATABASE_URL` 환경 변수 확인
- PostgreSQL 서비스가 실행 중인지 확인
- Internal Database URL 사용 확인

### API가 응답하지 않음

- Logs 탭에서 에러 확인
- 환경 변수 확인
- 재배포 시도

## 성공 확인 체크리스트

- [x] Health Check 응답 정상 (`/`)
- [ ] API 문서 접근 가능 (`/docs`)
- [ ] 데이터베이스 연결 확인
- [ ] 캡처 API 테스트 성공
- [ ] Chrome Extension 연결 테스트
- [ ] Android App 연결 테스트

## 참고

- Render 무료 플랜은 Sleep Mode가 있습니다 (15분 비활성 시)
- 첫 요청 시 약 30초 지연될 수 있습니다
- 프로덕션 사용 시 Starter 플랜 ($7/월) 권장

