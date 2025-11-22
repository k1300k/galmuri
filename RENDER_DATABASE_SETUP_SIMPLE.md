# Render PostgreSQL 연결 - 간단한 방법 (실제 UI 기준)

## 가장 쉬운 방법 (실제 Render UI 기준)

### 1단계: PostgreSQL 서비스 생성

1. Render 대시보드: https://dashboard.render.com
2. **"New +"** → **"PostgreSQL"** 클릭
3. 설정:
   - Name: `galmuri-diary-db`
   - Plan: `Free`
4. **"Create Database"** 클릭
5. 생성 완료 대기 (1-2분)

### 2단계: 연결 문자열 복사

1. 생성된 PostgreSQL 서비스 클릭
2. **"Info"** 탭 확인
3. **"Internal Database URL"** 찾기
4. **전체 URL 복사** (예: `postgresql://user:pass@host:port/db`)
   - 📋 복사 버튼 클릭 또는 직접 선택하여 복사
   postgresql://galmuri_diary_db_user:c0JV2Mk5eBfkh7skhWHVqzrvO2Rm6aU1@dpg-d4gdaovdiees739q73ng-a/galmuri_diary_db

### 3단계: Web Service 생성

1. **"New +"** → **"Web Service"** 클릭
2. GitHub 저장소 선택
3. 설정 입력:
   - Name: `galmuri-diary-api`
   - Root Directory: `backend`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn presentation.main:app --host 0.0.0.0 --port $PORT`
4. **"Create Web Service"** 클릭

### 4단계: 환경 변수 추가 (중요!)

1. Web Service가 생성되면 클릭
2. 좌측 메뉴에서 **"Environment"** 탭 클릭
3. **"Add Environment Variable"** 버튼 클릭
4. 입력:
   - **Key**: `DATABASE_URL` (정확히 이렇게 입력)
   - **Value**: 2단계에서 복사한 Internal Database URL 붙여넣기
5. **"Save Changes"** 클릭
6. 자동으로 재배포 시작됨

### 5단계: 확인

1. **"Logs"** 탭에서 배포 로그 확인
2. 에러가 없으면 성공!
3. API 테스트: `https://your-app.onrender.com/docs`

---

## 문제 해결

### "Link Database" 버튼이 안 보여요

→ **정상입니다!** Render UI가 업데이트되면서 이 버튼이 없는 경우가 많습니다.
→ **해결**: 위의 4단계처럼 수동으로 `DATABASE_URL` 환경 변수를 추가하세요.

### Internal Database URL이 안 보여요

1. PostgreSQL 서비스 → **"Info"** 탭 확인
2. 또는 **"Connections"** 탭 확인
3. "Internal Database URL" 또는 "Connection String" 찾기
4. 없으면 "External Database URL" 사용 (보안 주의)

### 연결이 안 돼요

1. **Value 확인**: 전체 URL이 정확히 복사되었는지 확인
2. **재배포**: 환경 변수 저장 후 수동 재배포
3. **로그 확인**: "Logs" 탭에서 에러 메시지 확인

---

## 실제 화면 예시

### PostgreSQL Info 탭에서 보이는 것:

```
Internal Database URL
postgresql://galmuri_user:abc123@dpg-xxxxx-a:5432/galmuri_db

[복사] 버튼
```

### Web Service Environment 탭에서:

```
Add Environment Variable

Key:   [DATABASE_URL                    ]
Value: [postgresql://galmuri_user:...   ]  [Link Database] <- 이 버튼이 없을 수 있음

[Save Changes]
```

→ 버튼이 없으면 Value에 직접 붙여넣기!

---

## 요약

1. ✅ PostgreSQL 생성
2. ✅ Internal Database URL 복사
3. ✅ Web Service 생성
4. ✅ Environment → Add Variable → `DATABASE_URL` = 복사한 URL
5. ✅ Save Changes
6. ✅ 완료!

