# Render 배포 가이드

## Render란?

Render는 **개발자 친화적인 클라우드 플랫폼**으로, FastAPI 배포에 매우 적합합니다.

### 장점

✅ **Python 직접 지원** - FastAPI 그대로 배포 가능
✅ **PostgreSQL 무료 제공** - 데이터베이스 무료 티어
✅ **자동 HTTPS** - SSL 인증서 자동 설정
✅ **무료 티어** - 개인 프로젝트에 충분
✅ **쉬운 배포** - GitHub 연동으로 자동 배포
✅ **환경 변수 관리** - 대시보드에서 쉽게 설정
✅ **로그 확인** - 실시간 로그 확인 가능

### 무료 티어 제한

- **Web Service**: 750시간/월 (약 31일)
- **PostgreSQL**: 90일 무료, 이후 $7/월
- **Sleep Mode**: 15분 비활성 시 자동 슬립 (무료)
- **Build Time**: 10분 제한

## Render 배포 단계

### 1단계: GitHub 저장소 준비

```bash
# Git 초기화 (아직 안 했다면)
cd /Users/john/gal
git init
git add .
git commit -m "Initial commit"

# GitHub에 푸시
git remote add origin https://github.com/yourusername/galmuri-diary.git
git push -u origin main
```

### 2단계: Render 대시보드 설정

1. **Render.com 가입**
   - https://render.com 접속
   - GitHub 계정으로 로그인

2. **New Web Service 생성**
   - Dashboard → "New +" → "Web Service"
   - GitHub 저장소 선택

3. **서비스 설정**

```
Name: galmuri-diary-api
Region: Singapore (또는 가장 가까운 지역)
Branch: main
Root Directory: backend
Runtime: Python 3
Build Command: pip install -r requirements.txt
Start Command: uvicorn presentation.main:app --host 0.0.0.0 --port $PORT
```

### 3단계: PostgreSQL 데이터베이스 추가

1. **New PostgreSQL 생성**
   - Dashboard → "New +" → "PostgreSQL"
   - Name: `galmuri-diary-db`
   - Plan: Free (90일 무료)

2. **데이터베이스 연결**
   - Web Service → Environment → Add Environment Variable
   - `DATABASE_URL` 추가 (PostgreSQL 서비스에서 자동 제공)

### 4단계: 환경 변수 설정

Web Service → Environment에서 추가:

```bash
DATABASE_URL=<PostgreSQL 연결 문자열>
API_KEY_SECRET=your_secret_key_here
OCR_LANGUAGE=kor+eng
CORS_ORIGINS=https://your-app.onrender.com
PYTHON_VERSION=3.11
```

### 5단계: 배포

- GitHub에 푸시하면 자동 배포
- 또는 Manual Deploy 클릭

## 필요한 코드 수정

### 1. PostgreSQL Repository 생성

`backend/infrastructure/postgres_repository.py` 생성 필요:

```python
import os
from sqlalchemy import create_engine, Column, String, Text, DateTime, Boolean, Enum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from domain.entities import GalmuriItem, OCRStatus, Platform
from domain.repositories import IGalmuriRepository

Base = declarative_base()

class GalmuriItemModel(Base):
    __tablename__ = "galmuri_items"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), nullable=False, index=True)
    image_data = Column(Text, nullable=False)
    source_url = Column(String(2048), nullable=True)
    page_title = Column(String(512), nullable=False)
    memo_content = Column(Text, nullable=True)
    ocr_text = Column(Text, nullable=True)
    ocr_status = Column(String(20), nullable=False)
    platform = Column(String(20), nullable=False)
    is_synced = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, nullable=False)
    updated_at = Column(DateTime, nullable=False)

class PostgresGalmuriRepository(IGalmuriRepository):
    def __init__(self, database_url: str):
        self.engine = create_engine(database_url)
        Base.metadata.create_all(self.engine)
        self.Session = sessionmaker(bind=self.engine)
    
    # ... 구현 ...
```

### 2. main.py 수정

```python
import os
from infrastructure.postgres_repository import PostgresGalmuriRepository
from infrastructure.local_repository import LocalGalmuriRepository

def get_repository() -> IGalmuriRepository:
    """Get repository instance"""
    database_url = os.getenv("DATABASE_URL")
    
    if database_url:
        # Production: PostgreSQL
        return PostgresGalmuriRepository(database_url)
    else:
        # Development: SQLite
        return LocalGalmuriRepository(db_path="galmuri.db")
```

### 3. requirements.txt 확인

```txt
fastapi==0.109.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
sqlalchemy==2.0.25
psycopg2-binary==2.9.9  # PostgreSQL 드라이버
# ... 기타 의존성 ...
```

## 배포 후 확인

### 1. 서비스 URL 확인

Render 대시보드에서:
- Web Service URL: `https://galmuri-diary-api.onrender.com`
- API 문서: `https://galmuri-diary-api.onrender.com/docs`

### 2. 헬스 체크

```bash
curl https://galmuri-diary-api.onrender.com/
```

### 3. 로그 확인

Render 대시보드 → Logs 탭에서 실시간 로그 확인

## Render vs 다른 플랫폼

| 기능 | Render | Railway | Vercel |
|------|--------|---------|--------|
| Python 지원 | ✅ 직접 | ✅ 직접 | ⚠️ Serverless |
| PostgreSQL | ✅ 무료 90일 | ✅ 무료 | ❌ 없음 |
| SQLite | ❌ 불가 | ✅ 가능 | ❌ 불가 |
| 무료 티어 | ✅ 750시간/월 | ✅ $5 크레딧 | ✅ 무제한 |
| Sleep Mode | ✅ 15분 | ❌ 없음 | ❌ 없음 |
| 배포 난이도 | ⭐⭐ 쉬움 | ⭐⭐ 쉬움 | ⭐⭐⭐ 보통 |

## 문제 해결

### Build 실패

```bash
# requirements.txt 확인
# Python 버전 확인 (3.11 권장)
```

### 데이터베이스 연결 실패

```bash
# DATABASE_URL 환경 변수 확인
# PostgreSQL 서비스가 실행 중인지 확인
```

### Sleep Mode 문제

- 무료 티어는 15분 비활성 시 자동 슬립
- 첫 요청 시 약 30초 지연 가능
- 해결: Keep-alive 서비스 사용 또는 유료 플랜

## 비용

### 무료 플랜
- Web Service: 750시간/월 (약 31일)
- PostgreSQL: 90일 무료

### 유료 플랜 (필요 시)
- Starter: $7/월 (무제한 시간, PostgreSQL 포함)
- Professional: $25/월 (더 많은 리소스)

## 추천 설정

### MVP 단계
- Web Service: Free
- PostgreSQL: Free (90일)
- Sleep Mode 허용

### 프로덕션
- Web Service: Starter ($7/월)
- PostgreSQL: Starter에 포함
- Sleep Mode 없음

## 결론

**Render는 FastAPI 배포에 매우 적합합니다!**

✅ **장점:**
- Python 직접 지원
- PostgreSQL 무료 제공
- 쉬운 배포
- 무료 티어 충분

⚠️ **주의사항:**
- Sleep Mode (무료 플랜)
- 90일 후 PostgreSQL 유료 전환

**추천도: ⭐⭐⭐⭐⭐**

