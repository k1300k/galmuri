# Galmuri Diary 아키텍처 설명

## 프로젝트 구조

이 프로젝트는 **하이브리드 아키텍처**입니다:

```
┌─────────────────────────────────────────┐
│         클라이언트 (Client)              │
├─────────────────────────────────────────┤
│  Chrome Extension (JavaScript)          │
│  Android App (Flutter)                   │
│  Flutter Web (선택사항)                  │
└─────────────────────────────────────────┘
                    ↓ API 호출
┌─────────────────────────────────────────┐
│         백엔드 서비스 (Backend)          │
├─────────────────────────────────────────┤
│  FastAPI (Python)                       │
│  - REST API 서버                         │
│  - PostgreSQL 데이터베이스              │
│  - OCR 처리                              │
└─────────────────────────────────────────┘
```

## 각 구성 요소의 역할

### 1. 백엔드 서비스 (FastAPI - Python)

**위치**: `/backend`

**역할**:
- ✅ **REST API 서버** 제공
- ✅ 데이터 저장 및 관리 (PostgreSQL)
- ✅ OCR 처리 (Tesseract)
- ✅ 인증 및 권한 관리

**기술 스택**:
- FastAPI (Python 웹 프레임워크)
- PostgreSQL (데이터베이스)
- Tesseract (OCR)

**배포**:
- Render, Railway 등에 배포
- API 엔드포인트 제공: `https://your-app.onrender.com`

### 2. Chrome Extension (JavaScript)

**위치**: `/extension`

**역할**:
- ✅ 웹 페이지 캡처
- ✅ API 호출하여 데이터 저장
- ✅ 로컬 저장소 (IndexedDB)

**기술 스택**:
- Vanilla JavaScript
- Chrome Extension Manifest V3
- IndexedDB (로컬 저장)

### 3. Android App (Flutter)

**위치**: `/android`

**역할**:
- ✅ 모바일에서 이미지 캡처
- ✅ API 호출하여 데이터 저장
- ✅ 로컬 저장소 (SQLite)

**기술 스택**:
- Flutter (Dart)
- SQLite (로컬 저장)
- HTTP 클라이언트 (Dio)

**배포**:
- APK로 빌드하여 안드로이드 기기에 설치

### 4. Flutter Web (선택사항)

**위치**: `/android` (같은 프로젝트)

**역할**:
- ✅ 웹 브라우저에서 실행 가능한 Flutter 앱
- ✅ API 호출하여 데이터 관리

**기술 스택**:
- Flutter Web
- 인메모리 저장소 (웹에서는 SQLite 불가)

**배포**:
- Vercel, Netlify 등에 정적 사이트로 배포 가능

## Flutter의 역할

### ❌ Flutter는 백엔드 서비스가 아닙니다

**Flutter는 클라이언트 앱**입니다:
- Android App (모바일)
- Flutter Web (웹 브라우저)

### ✅ 백엔드 서비스는 FastAPI입니다

**FastAPI가 실제 서비스**입니다:
- API 서버
- 데이터베이스 관리
- 비즈니스 로직

## 데이터 흐름

```
사용자 액션
    ↓
[Chrome Extension 또는 Android App]
    ↓
API 호출 (HTTP/HTTPS)
    ↓
[FastAPI 백엔드 서버]
    ↓
[PostgreSQL 데이터베이스]
    ↓
응답 반환
    ↓
[클라이언트 앱]
    ↓
로컬 저장소 (IndexedDB 또는 SQLite)
```

## 배포 구조

### 현재 배포

```
┌─────────────────┐
│  Render         │ ← FastAPI 백엔드 (서비스)
│  (Python)       │
└─────────────────┘
         ↑
         │ API 호출
         │
┌─────────────────┐
│  사용자 기기     │
│  - Extension    │ ← 클라이언트 (Flutter 아님)
│  - Android App  │ ← Flutter 앱 (클라이언트)
└─────────────────┘
```

### Flutter Web 배포 (선택사항)

만약 Flutter Web을 배포한다면:

```
┌─────────────────┐
│  Vercel/Netlify │ ← Flutter Web (프론트엔드)
│  (정적 사이트)   │
└─────────────────┘
         ↓ API 호출
┌─────────────────┐
│  Render         │ ← FastAPI 백엔드 (서비스)
│  (Python)       │
└─────────────────┘
```

## 요약

### ❌ 오해하기 쉬운 점

- "Flutter로 서비스한다" = ❌ 잘못된 이해
- Flutter는 클라이언트 앱일 뿐

### ✅ 올바른 이해

- **백엔드 서비스**: FastAPI (Python)
- **클라이언트 앱**: 
  - Chrome Extension (JavaScript)
  - Android App (Flutter)
  - Flutter Web (선택사항)

### 현재 구조

1. **서비스 (백엔드)**: FastAPI → Render에 배포
2. **클라이언트**: 
   - Extension → 브라우저에 설치
   - Android App → APK로 설치
   - Flutter Web → 선택사항 (현재는 백엔드만 배포)

## Flutter Web을 서비스로 만들고 싶다면?

Flutter Web을 프론트엔드로 배포할 수 있습니다:

1. **Flutter Web 빌드**
   ```bash
   cd android
   flutter build web
   ```

2. **Vercel/Netlify에 배포**
   - `build/web` 폴더 업로드
   - 정적 사이트로 호스팅

3. **구조**
   ```
   Flutter Web (Vercel) → FastAPI (Render)
   ```

하지만 현재는:
- **백엔드만 배포**: FastAPI (Render)
- **클라이언트는 로컬 설치**: Extension, Android App

## 결론

- **서비스 (백엔드)**: FastAPI (Python) - Render에 배포됨
- **Flutter**: 클라이언트 앱 (Android, Web) - 사용자 기기에 설치
- **현재 상태**: 백엔드 API만 배포, 클라이언트는 로컬 설치

Flutter로 웹 프론트엔드를 만들고 싶다면 추가로 개발할 수 있습니다!

