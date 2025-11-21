# Vercel 배포 가이드

## 현재 프로젝트 구조

이 프로젝트는 **하이브리드 아키텍처**입니다:

1. **백엔드**: FastAPI (Python) - API 서버
2. **Chrome Extension**: 클라이언트 사이드 확장 프로그램
3. **Android App**: Flutter 앱 (모바일/웹)

## Vercel 배포 옵션

### ✅ 옵션 1: 백엔드만 Vercel에 배포 (권장)

Vercel은 Python Serverless Functions를 지원하므로 FastAPI를 배포할 수 있습니다.

#### 장점
- 무료 티어 제공
- 자동 HTTPS
- 글로벌 CDN
- 쉬운 배포

#### 제한사항
- SQLite 파일 시스템 제한 (Serverless 환경)
- 대신 PostgreSQL, MongoDB 등 외부 DB 필요
- OCR 처리 시간 제한 (10초)

#### 배포 방법

```bash
# 1. vercel.json 생성
```

```json
{
  "version": 2,
  "builds": [
    {
      "src": "backend/presentation/main.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "backend/presentation/main.py"
    }
  ]
}
```

```bash
# 2. Vercel CLI 설치
npm i -g vercel

# 3. 배포
cd /Users/john/gal
vercel
```

### ✅ 옵션 2: 웹 프론트엔드 추가 + Vercel 배포

Flutter 웹 앱을 Vercel에 배포하고, 백엔드는 별도로 배포:

1. **프론트엔드**: Flutter Web → Vercel (정적 사이트)
2. **백엔드**: FastAPI → Railway/Render/Fly.io

#### 장점
- 프론트엔드와 백엔드 분리
- 각각 최적의 플랫폼 사용
- 확장성 좋음

### ✅ 옵션 3: 전체 스택을 다른 플랫폼에 배포

Vercel 대신 다른 플랫폼 사용:

#### Railway (권장)
- FastAPI 직접 지원
- PostgreSQL 무료 제공
- 쉬운 배포

#### Render
- Python 지원
- 무료 티어
- PostgreSQL 제공

#### Fly.io
- 글로벌 배포
- Docker 지원
- SQLite 가능

## Vercel 배포 시 필요한 수정사항

### 1. 데이터베이스 변경

SQLite → PostgreSQL 또는 MongoDB

```python
# backend/infrastructure/postgres_repository.py 생성 필요
```

### 2. 환경 변수 설정

Vercel 대시보드에서:
- `DATABASE_URL`
- `API_KEY_SECRET`
- `OCR_LANGUAGE`

### 3. 파일 시스템 제한

- SQLite 파일 저장 불가
- 이미지는 S3, Cloudinary 등 사용
- 또는 Base64로 직접 저장 (제한적)

## 추천 배포 전략

### MVP 단계 (현재)

```
┌─────────────────┐
│ Chrome Extension│ → 로컬 IndexedDB
│ Android App     │ → 로컬 SQLite
└─────────────────┘
         ↓ (선택적)
┌─────────────────┐
│ FastAPI Backend │ → Railway/Render
│ (동기화용)      │
└─────────────────┘
```

### 프로덕션 단계

```
┌─────────────────┐
│ Web Frontend    │ → Vercel (Flutter Web)
│ (선택사항)      │
└─────────────────┘
         ↓
┌─────────────────┐
│ FastAPI Backend │ → Railway (PostgreSQL)
│                 │
└─────────────────┘
```

## 빠른 시작: Railway 배포 (Vercel 대안)

Railway는 FastAPI + SQLite를 직접 지원합니다:

```bash
# 1. Railway CLI 설치
npm i -g @railway/cli

# 2. 로그인
railway login

# 3. 프로젝트 초기화
cd backend
railway init

# 4. 배포
railway up
```

## 결론

**Vercel 사용 가능 여부:**
- ✅ 가능: FastAPI를 Serverless Functions로 변환
- ⚠️ 제한: SQLite 사용 불가, 외부 DB 필요
- 💡 추천: Railway 또는 Render 사용 (더 적합)

**가장 쉬운 방법:**
1. 백엔드: Railway 배포 (PostgreSQL 무료 제공)
2. 프론트엔드: Flutter Web → Vercel 배포 (선택사항)

