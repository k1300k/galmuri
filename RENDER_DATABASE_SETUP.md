# Render PostgreSQL 데이터베이스 연결 상세 가이드

## 개요

Render에서 PostgreSQL 데이터베이스를 Web Service에 연결하는 방법을 단계별로 설명합니다.

## 방법 1: 수동 연결 (실제 UI 기준) ⭐ 권장

⚠️ **참고**: Render UI 업데이트로 "Link Database" 버튼이 없는 경우가 많습니다. 아래 수동 방법을 사용하세요.

📚 **더 간단한 가이드**: `RENDER_DATABASE_SETUP_SIMPLE.md` 참고

### Step 1: PostgreSQL 서비스 생성

1. Render 대시보드 접속: https://dashboard.render.com
2. **"New +"** 버튼 클릭
3. **"PostgreSQL"** 선택
4. 설정 입력:
   - **Name**: `galmuri-diary-db` (원하는 이름)
   - **Database**: `galmuri` (자동 생성되거나 수동 입력)
   - **User**: `galmuri_user` (자동 생성되거나 수동 입력)
   - **Region**: `Singapore` (또는 가장 가까운 지역)
   - **Plan**: `Free` (90일 무료) 또는 `Starter` ($7/월)
5. **"Create Database"** 클릭
6. 데이터베이스 생성 완료 대기 (약 1-2분)

### Step 2: Web Service 생성 후 데이터베이스 연결

**Web Service 생성:**
1. **"New +"** → **"Web Service"** 클릭
2. GitHub 저장소 선택
3. 서비스 설정 입력:
   - Name: `galmuri-diary-api`
   - Region: `Singapore`
   - Branch: `main`
   - Root Directory: `backend`
   - Runtime: `Python 3`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn presentation.main:app --host 0.0.0.0 --port $PORT`
4. **"Create Web Service"** 클릭
5. Web Service 생성 완료 대기 (약 2-3분)

**데이터베이스 연결 (Web Service 생성 후):**
1. 생성된 Web Service 클릭
2. 좌측 메뉴에서 **"Environment"** 탭 클릭
3. **"Add Environment Variable"** 버튼 클릭
4. Key 입력란에 `DATABASE_URL` 입력
5. Value 입력란 옆의 **"Link Database"** 또는 **"Select Database"** 버튼 클릭
   - ⚠️ 이 버튼이 보이지 않으면 아래 "수동 연결" 방법 사용
6. 드롭다운에서 생성한 PostgreSQL 서비스 선택
7. Render가 자동으로 연결 문자열 생성
8. **"Save Changes"** 클릭

### 장점
- ✅ 자동으로 연결 문자열 생성
- ✅ 환경 변수 자동 설정
- ✅ 실수 방지
- ✅ 가장 간단한 방법

---

## 방법 2: 수동 연결 (더 세밀한 제어)

### Step 1: PostgreSQL 연결 정보 확인

1. Render 대시보드에서 PostgreSQL 서비스 클릭
2. **"Info"** 탭 클릭 (또는 상단에 표시된 정보 확인)
3. 다음 정보 확인:
   - **Internal Database URL**: 같은 Render 네트워크 내에서 사용 (권장)
     - 형식: `postgresql://user:password@hostname:port/database`
     - 이 URL을 그대로 복사하여 사용
   - **External Database URL**: 외부에서 접근 가능 (로컬 개발용)
   - 또는 개별 정보:
     - **Host**: 데이터베이스 호스트 주소
     - **Port**: 포트 번호 (기본: 5432)
     - **Database**: 데이터베이스 이름
     - **User**: 사용자 이름
     - **Password**: 비밀번호 (처음 생성 시 표시, 이후에는 재설정 필요)

**💡 팁**: Internal Database URL을 그대로 복사하는 것이 가장 쉽습니다!

### Step 2: 연결 문자열 구성

**형식:**
```
postgresql://[user]:[password]@[host]:[port]/[database]
```

**예시:**
```
postgresql://galmuri_user:abc123xyz@dpg-xxxxx-a.singapore-postgres.render.com:5432/galmuri_db
```

**Internal URL 예시:**
```
postgresql://galmuri_user:abc123xyz@dpg-xxxxx-a:5432/galmuri_db
```

### Step 3: Web Service에 환경 변수 추가

1. Render 대시보드에서 Web Service 클릭
2. 좌측 메뉴에서 **"Environment"** 클릭
3. **"Add Environment Variable"** 버튼 클릭
4. 다음 정보 입력:
   - **Key**: `DATABASE_URL`
   - **Value**: 위에서 구성한 연결 문자열
   - **Sync**: ✅ 체크 (권장 - 다른 환경과 동기화)
5. **"Save Changes"** 클릭

### Step 4: 추가 환경 변수 (선택사항)

다음 환경 변수도 추가할 수 있습니다:

| Key | Value | 설명 |
|-----|-------|------|
| `PYTHON_VERSION` | `3.11` | Python 버전 |
| `OCR_LANGUAGE` | `kor+eng` | OCR 언어 설정 |
| `CORS_ORIGINS` | `https://your-app.onrender.com` | CORS 허용 도메인 |
| `API_KEY_SECRET` | `your_secret_key` | API 키 (선택사항) |

### Step 5: 서비스 재배포

1. 환경 변수 저장 후 자동으로 재배포 시작
2. 또는 **"Manual Deploy"** → **"Deploy latest commit"** 클릭
3. 배포 로그에서 데이터베이스 연결 확인

---

## 방법 3: Render Blueprint 사용 (YAML 파일)

### Step 1: render.yaml 파일 확인

프로젝트 루트에 `render.yaml` 파일이 있습니다:

```yaml
services:
  - type: web
    name: galmuri-diary-api
    env: python
    region: singapore
    plan: free
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn presentation.main:app --host 0.0.0.0 --port $PORT
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: galmuri-diary-db
          property: connectionString

databases:
  - name: galmuri-diary-db
    plan: free
    databaseName: galmuri
    user: galmuri_user
```

### Step 2: Blueprint로 배포

1. Render 대시보드에서 **"New +"** → **"Blueprint"** 선택
2. GitHub 저장소 선택
3. Render가 `render.yaml` 파일을 자동으로 읽어서 설정
4. 모든 서비스와 데이터베이스가 자동으로 생성 및 연결됨
5. **"Apply"** 클릭

### 장점
- ✅ 한 번에 모든 리소스 생성
- ✅ 설정 파일로 관리 (버전 관리 가능)
- ✅ 재현 가능한 배포

---

## 연결 확인 방법

### 방법 1: 로그 확인

1. Web Service → **"Logs"** 탭
2. 배포 로그에서 다음 메시지 확인:
   ```
   Database connection successful
   ```
   또는
   ```
   Connected to PostgreSQL
   ```

### 방법 2: API 테스트

```bash
# Health check
curl https://your-app.onrender.com/

# API 문서 확인
curl https://your-app.onrender.com/docs
```

### 방법 3: 데이터베이스 직접 확인

1. PostgreSQL 서비스 → **"Connect"** 탭
2. **"psql"** 명령어 복사
3. 로컬 터미널에서 실행
4. 테이블 확인:
   ```sql
   \dt  -- 테이블 목록
   SELECT * FROM galmuri_items LIMIT 5;  -- 데이터 확인
   ```

---

## 문제 해결

### 문제 1: "Connection refused"

**원인**: Internal URL을 사용하지 않음

**해결**:
- Internal Database URL 사용 확인
- 또는 External URL 사용 (보안 주의)

### 문제 2: "Authentication failed"

**원인**: 비밀번호 오류

**해결**:
- PostgreSQL 서비스에서 비밀번호 재설정
- 환경 변수 업데이트

### 문제 3: "Database does not exist"

**원인**: 데이터베이스 이름 오류

**해결**:
- PostgreSQL 서비스의 Info 탭에서 정확한 데이터베이스 이름 확인
- 연결 문자열 수정

### 문제 4: 환경 변수가 적용되지 않음

**원인**: 재배포 필요

**해결**:
- 환경 변수 저장 후 수동 재배포
- 또는 자동 재배포 대기

---

## 보안 주의사항

### ✅ 권장 사항

1. **Internal URL 사용**: 같은 Render 네트워크 내에서만 접근
2. **환경 변수 암호화**: Render가 자동으로 처리
3. **비밀번호 복잡도**: 강력한 비밀번호 사용

### ⚠️ 주의사항

1. **External URL**: 외부에서 접근 가능하므로 보안 주의
2. **환경 변수 노출**: 로그에 출력하지 않기
3. **토큰 관리**: Personal Access Token 안전하게 보관

---

## 다음 단계

데이터베이스 연결 완료 후:

1. ✅ API 테스트: `/docs` 엔드포인트 확인
2. ✅ 데이터 저장 테스트: `/api/capture` 엔드포인트 테스트
3. ✅ 로그 모니터링: 정상 작동 확인
4. ✅ 백업 설정: PostgreSQL 자동 백업 확인

---

## 참고 자료

- [Render PostgreSQL 문서](https://render.com/docs/databases)
- [Render 환경 변수 문서](https://render.com/docs/environment-variables)
- [PostgreSQL 연결 문자열 형식](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)

