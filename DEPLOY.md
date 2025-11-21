# Galmuri Diary 배포 가이드

## 현재 아키텍처

이 프로젝트는 **하이브리드 시스템**입니다:

- **백엔드**: FastAPI (Python) - REST API 서버
- **클라이언트**: 
  - Chrome Extension (브라우저 확장 프로그램)
  - Android App (Flutter)
  - Flutter Web (웹 버전)

## 배포 옵션 비교

| 플랫폼 | 백엔드 지원 | 프론트엔드 지원 | 데이터베이스 | 무료 티어 | 추천도 |
|--------|------------|----------------|-------------|----------|--------|
| **Vercel** | ⚠️ Serverless Functions | ✅ 정적 사이트 | ❌ SQLite 불가 | ✅ 있음 | ⭐⭐⭐ |
| **Railway** | ✅ 직접 지원 | ❌ | ✅ PostgreSQL 무료 | ✅ 있음 | ⭐⭐⭐⭐⭐ |
| **Render** | ✅ 직접 지원 | ✅ 정적 사이트 | ✅ PostgreSQL 무료 | ✅ 있음 | ⭐⭐⭐⭐ |
| **Fly.io** | ✅ Docker 지원 | ✅ 정적 사이트 | ✅ SQLite 가능 | ✅ 있음 | ⭐⭐⭐⭐ |
| **Heroku** | ✅ 직접 지원 | ✅ | ✅ PostgreSQL | ❌ 없음 | ⭐⭐⭐ |

## 추천 배포 전략

### 🥇 옵션 1: Railway (가장 추천)

**이유:**
- FastAPI 직접 지원
- PostgreSQL 무료 제공
- 쉬운 배포
- SQLite → PostgreSQL 마이그레이션 간단

**배포 방법:**

```bash
# 1. Railway CLI 설치
npm i -g @railway/cli

# 2. 로그인
railway login

# 3. 프로젝트 초기화
cd backend
railway init

# 4. PostgreSQL 추가
railway add postgresql

# 5. 환경 변수 설정
railway variables set DATABASE_URL=$DATABASE_URL

# 6. 배포
railway up
```

### 🥈 옵션 2: Vercel (프론트엔드 중심)

**이유:**
- 웹 프론트엔드 배포에 최적
- 백엔드는 Serverless Functions로 변환 필요
- SQLite 사용 불가 → PostgreSQL 필요

**배포 방법:**

```bash
# 1. Vercel CLI 설치
npm i -g vercel

# 2. 배포
cd /Users/john/gal
vercel

# 3. 환경 변수 설정 (Vercel 대시보드)
# - DATABASE_URL
# - API_KEY_SECRET
```

**필요한 수정:**
- `vercel.json` 생성 (이미 생성됨)
- SQLite → PostgreSQL 변경
- 이미지 저장소 변경 (S3, Cloudinary 등)

### 🥉 옵션 3: Render

**이유:**
- Python 직접 지원
- PostgreSQL 무료
- 정적 사이트 호스팅 가능

**배포 방법:**

1. Render.com 가입
2. "New Web Service" 선택
3. GitHub 저장소 연결
4. Build Command: `pip install -r requirements.txt`
5. Start Command: `uvicorn presentation.main:app --host 0.0.0.0 --port $PORT`

## Vercel 배포 시 주의사항

### ❌ 제한사항

1. **SQLite 사용 불가**
   - Serverless 환경에서는 파일 시스템이 읽기 전용
   - PostgreSQL, MongoDB 등 외부 DB 필요

2. **파일 저장 제한**
   - 이미지는 Base64로 저장하거나 S3 사용
   - 로컬 파일 저장 불가

3. **실행 시간 제한**
   - 무료: 10초
   - OCR 처리 시간 고려 필요

### ✅ 해결 방법

1. **데이터베이스 변경**
   ```python
   # PostgreSQL 사용
   # backend/infrastructure/postgres_repository.py 생성
   ```

2. **이미지 저장소**
   - Cloudinary (무료 티어)
   - AWS S3
   - 또는 Base64로 직접 저장 (제한적)

3. **OCR 처리**
   - 클라이언트 사이드에서 처리 (Tesseract.js)
   - 또는 별도 OCR 서비스 사용

## 빠른 배포 (Railway 추천)

```bash
# 1. Railway 설치 및 로그인
npm i -g @railway/cli
railway login

# 2. 프로젝트 설정
cd backend
railway init

# 3. PostgreSQL 추가
railway add postgresql

# 4. 배포
railway up
```

## 환경 변수 설정

모든 플랫폼에서 필요한 환경 변수:

```bash
DATABASE_URL=postgresql://user:pass@host:port/db
API_KEY_SECRET=your_secret_key
OCR_LANGUAGE=kor+eng
CORS_ORIGINS=https://yourdomain.com
```

## 결론

**Vercel 사용 가능 여부:**
- ✅ **가능하지만 제한적**
- ⚠️ SQLite → PostgreSQL 변경 필요
- ⚠️ 파일 저장소 변경 필요

**추천:**
- **Railway**: 가장 쉬운 배포, PostgreSQL 무료 제공
- **Render**: Railway 대안, 무료 티어 제공
- **Vercel**: 프론트엔드 중심, 백엔드는 제한적

**현재 MVP 단계에서는:**
- 로컬 개발: 현재 구조 유지
- 프로덕션: Railway 또는 Render 추천

