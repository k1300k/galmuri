# Render 빌드 에러 해결 가이드

## 문제: Pillow 빌드 실패

**에러 메시지:**
```
error: subprocess-exited-with-error
× Getting requirements to build wheel did not run successfully.
KeyError: '__version__'
```

**원인:**
- Python 3.13과 Pillow 10.2.0의 호환성 문제
- Render가 기본적으로 Python 3.13을 사용

## 해결 방법

### 방법 1: Python 버전 고정 (권장) ⭐

**Render Web Service 설정에서:**

1. Web Service → **"Settings"** 탭
2. **"Python Version"** 또는 **"Environment"** 섹션 찾기
3. Python 버전을 **`3.11`**로 설정
4. **"Save Changes"** 클릭
5. 재배포

**또는 환경 변수로 설정:**

1. Web Service → **"Environment"** 탭
2. **"Add Environment Variable"** 클릭
3. Key: `PYTHON_VERSION`
4. Value: `3.11`
5. **"Save Changes"** 클릭

### 방법 2: Pillow 버전 업데이트

**requirements.txt 수정:**

```txt
# 기존
pillow==10.2.0

# 변경
pillow>=10.3.0
```

또는 최신 버전:

```txt
pillow>=11.0.0
```

### 방법 3: runtime.txt 파일 생성

**backend/runtime.txt 파일 생성:**

```
python-3.11.0
```

Render가 자동으로 이 파일을 읽어서 Python 버전을 설정합니다.

### 방법 4: requirements.txt 최적화

Render에서는 테스트 의존성이 필요 없으므로:

```txt
# Render 배포용 (requirements.txt)
fastapi==0.109.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
pydantic-settings==2.1.0
sqlalchemy==2.0.25
alembic==1.13.1
python-multipart==0.0.6
pillow>=10.3.0  # Python 3.13 호환
pytesseract==0.3.10
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-dotenv==1.0.0
psycopg2-binary==2.9.9

# 테스트 의존성 제거 (Render에서 불필요)
# pytest==7.4.4
# pytest-asyncio==0.23.3
# httpx==0.26.0
# aiosqlite==0.19.0  # SQLite는 Render에서 사용하지 않음
```

## 빠른 해결 (가장 쉬움)

### Step 1: runtime.txt 생성

```bash
cd backend
echo "python-3.11.0" > runtime.txt
```

### Step 2: requirements.txt 수정

```txt
pillow>=10.3.0  # 기존 pillow==10.2.0 변경
```

### Step 3: GitHub에 푸시

```bash
git add backend/runtime.txt backend/requirements.txt
git commit -m "Fix: Python 3.11 and Pillow version for Render"
git push
```

### Step 4: Render 재배포

- Render가 자동으로 재배포 시작
- 또는 "Manual Deploy" 클릭

## 확인

배포 로그에서 다음을 확인:

```
✅ Installing pillow>=10.3.0
✅ Build succeeded
```

## 추가 최적화

### Build Command 수정 (선택사항)

Render Web Service 설정에서:

```
Build Command: pip install --upgrade pip && pip install -r requirements.txt
```

이렇게 하면 pip를 먼저 업그레이드한 후 패키지를 설치합니다.

## 문제가 계속되면

1. **로그 확인**: Render → Logs 탭에서 상세 에러 확인
2. **Python 버전 확인**: `python --version` 명령어로 확인
3. **Pillow 버전**: 최신 안정 버전 사용 (`pillow>=11.0.0`)
4. **의존성 확인**: 다른 패키지와의 충돌 확인

## 참고

- Python 3.13은 비교적 최신 버전이라 일부 패키지와 호환성 문제가 있을 수 있음
- Python 3.11은 안정적이고 대부분의 패키지와 호환됨
- Render는 기본적으로 최신 Python을 사용하므로 명시적으로 버전 지정 권장

