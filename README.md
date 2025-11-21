# Galmuri Diary v1.0 📚

**Hybrid Capture & Archiving System** - 웹과 모바일에서 스크린샷을 캡처하고 OCR로 텍스트를 추출하여 저장하는 지식 아카이빙 도구

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-green.svg)](https://fastapi.tiangolo.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 주요 기능

- 🌐 **Web Capture**: Chrome Extension을 통한 웹 페이지 캡처
- 📱 **Mobile App**: 안드로이드 앱으로 스크린샷 캡처 및 저장
- 🔍 **OCR Integration**: 이미지 내 텍스트 자동 추출 (한글/영문)
- 💾 **Local First**: 오프라인 우선 저장, 백그라운드 동기화
- 🔐 **API Key 인증**: 간단한 개인 API Key 기반 인증
- 🎯 **Smart Search**: 제목, 메모, OCR 텍스트 전체 검색

## 프로젝트 구조

```
gal/
├── backend/                    # FastAPI 백엔드 서버 (Clean Architecture)
│   ├── domain/                # Domain Layer (Entities, Repositories)
│   │   ├── entities.py       # GalmuriItem 엔티티
│   │   └── repositories.py   # Repository 인터페이스
│   ├── application/          # Application Layer (Use Cases, Services)
│   │   └── ocr_service.py    # OCR 서비스
│   ├── infrastructure/       # Infrastructure Layer (구현체)
│   │   └── local_repository.py  # SQLite 구현
│   ├── presentation/         # Presentation Layer (API)
│   │   └── main.py           # FastAPI 앱
│   ├── requirements.txt      # Python 의존성
│   └── run.py                # 서버 실행 스크립트
├── extension/                # Chrome Extension (Manifest V3)
│   ├── manifest.json         # Extension 설정
│   ├── popup/                # 팝업 UI
│   │   ├── popup.html
│   │   └── popup.js
│   ├── background/           # 백그라운드 스크립트
│   │   └── background.js
│   └── assets/               # 아이콘 등
├── android/                  # Android App (Flutter)
│   ├── lib/                  # Dart 소스 코드
│   │   ├── domain/          # Domain Layer
│   │   ├── data/            # Data Layer
│   │   └── presentation/    # Presentation Layer
│   ├── android/             # Android 네이티브 설정
│   └── pubspec.yaml         # Flutter 의존성
├── tests/                    # 테스트 코드
│   ├── test_ocr_service.py
│   ├── test_galmuri_service.py
│   ├── test_local_repository.py
│   └── test_api.py
├── scripts/                  # 유틸리티 스크립트
│   ├── setup.sh              # 자동 셋업
│   └── create_icons.py       # 아이콘 생성
└── prd.mdc                   # 제품 요구사항 정의서
```

## 빠른 시작 🚀

### 1. 자동 설치 (권장)

```bash
# 프로젝트 클론
git clone <repository-url>
cd gal

# 자동 설치 스크립트 실행
./scripts/setup.sh
```

### 2. 수동 설치

#### Backend 설정

```bash
cd backend

# 가상환경 생성 및 활성화
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# Tesseract 설치 (OCR에 필요)
# macOS:
brew install tesseract tesseract-lang

# Ubuntu/Debian:
sudo apt-get install tesseract-ocr tesseract-ocr-kor
```

#### 서버 실행

```bash
cd backend
source venv/bin/activate
python run.py
```

서버가 실행되면:
- 🌐 API 서버: http://localhost:8000
- 📚 API 문서: http://localhost:8000/docs

#### Extension 설치

1. Chrome에서 `chrome://extensions/` 접속
2. 우측 상단의 "개발자 모드" 활성화
3. "압축해제된 확장 프로그램을 로드합니다" 클릭
4. `extension` 폴더 선택

#### Extension 설정

1. 확장 프로그램 아이콘 클릭
2. "설정" 탭으로 이동
3. 다음 정보 입력:
   - **API Key**: 최소 10자 이상의 임의의 문자열 (예: `my_secret_key_1234567890`)
   - **User ID**: UUID 형식의 사용자 ID (예: `550e8400-e29b-41d4-a716-446655440000`)
   - **API URL**: `http://localhost:8000` (기본값)
4. "설정 저장" 클릭

> 💡 **Tip**: User ID는 [온라인 UUID 생성기](https://www.uuidgenerator.net/)에서 생성할 수 있습니다.

## 사용 방법

### 1. 웹 페이지 캡처

1. 저장하고 싶은 웹 페이지로 이동
2. Extension 아이콘 클릭
3. 자동으로 현재 페이지가 캡처됨
4. 메모 추가 (선택사항)
5. "저장" 버튼 클릭

### 2. 저장된 항목 조회

#### API로 조회:

```bash
# 모든 항목 조회
curl -H "X-API-Key: your_api_key" \
  http://localhost:8000/api/items/your_user_id

# 검색 (제목, 메모, OCR 텍스트)
curl -X POST -H "X-API-Key: your_api_key" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "your_user_id", "query": "검색어"}' \
  http://localhost:8000/api/search
```

## 아키텍처

### Clean Architecture 적용

이 프로젝트는 **Clean Architecture**와 **SOLID 원칙**을 따릅니다:

- **Domain Layer**: 비즈니스 로직과 엔티티 (프레임워크 독립적)
- **Application Layer**: 유스케이스와 서비스 (비즈니스 규칙)
- **Infrastructure Layer**: 데이터베이스, 외부 API 등의 구현체
- **Presentation Layer**: FastAPI 엔드포인트

### 데이터 흐름

```
Extension → API (Presentation) → Application Service → Domain Entity → Repository → Database
                                                    ↓
                                              OCR Service (비동기)
```

## 테스트 실행

```bash
cd backend
source venv/bin/activate

# 전체 테스트 실행
pytest

# 커버리지와 함께 실행
pytest --cov=. --cov-report=html

# 특정 테스트만 실행
pytest tests/test_ocr_service.py -v
```

## API 문서

서버 실행 후 다음 URL에서 자동 생성된 API 문서를 확인할 수 있습니다:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### 주요 엔드포인트

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/` | Health check |
| POST | `/api/capture` | 아이템 캡처 및 저장 |
| GET | `/api/items/{user_id}` | 사용자의 모든 아이템 조회 |
| POST | `/api/search` | 아이템 검색 |
| GET | `/api/item/{item_id}` | 특정 아이템 조회 |
| DELETE | `/api/item/{item_id}` | 아이템 삭제 |
| GET | `/api/items/{user_id}/unsynced` | 미동기화 아이템 조회 |

## 기술 스택

### Backend
- **Framework**: FastAPI 0.109+
- **Language**: Python 3.11+
- **Database**: SQLite (로컬), PostgreSQL (서버용)
- **OCR**: Tesseract, pytesseract
- **Testing**: pytest, pytest-asyncio

### Frontend (Extension)
- **Platform**: Chrome Extension Manifest V3
- **Language**: Vanilla JavaScript
- **Storage**: Chrome Storage API

### Mobile (Android)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **Architecture**: Clean Architecture
- **Local DB**: SQLite (sqflite)
- **HTTP**: Dio
- **State Management**: Riverpod

## 트러블슈팅

### Tesseract 관련 오류

**증상**: `Tesseract is not installed` 에러

**해결**:
```bash
# macOS
brew install tesseract tesseract-lang

# Ubuntu/Debian  
sudo apt-get install tesseract-ocr tesseract-ocr-kor tesseract-ocr-eng
```

### Extension이 API와 통신하지 못함

**증상**: "저장 실패" 에러

**해결**:
1. Backend 서버가 실행 중인지 확인
2. `manifest.json`의 `host_permissions`에 API URL이 포함되어 있는지 확인
3. CORS 설정 확인

### OCR이 텍스트를 추출하지 못함

**증상**: `ocr_text`가 비어있음

**해결**:
1. Tesseract 언어 팩 설치 확인: `tesseract --list-langs`
2. 이미지 품질 확인 (해상도, 선명도)
3. OCR은 비동기로 처리되므로 시간이 걸릴 수 있음

## 개발 가이드

### 새로운 기능 추가

1. **Domain Layer**: 엔티티나 비즈니스 로직이 필요한 경우
2. **Application Layer**: 새로운 유스케이스나 서비스
3. **Infrastructure Layer**: 외부 시스템 연동
4. **Presentation Layer**: API 엔드포인트
5. **Tests**: 테스트 코드 작성 (TDD 권장)

### 코딩 규칙

- SOLID 원칙 준수
- Clean Architecture 레이어 분리 유지
- 모든 비즈니스 로직에 테스트 코드 작성
- Type hints 사용 (Python)
- Docstring 작성

## 라이선스

MIT License

## 기여

이슈와 PR은 언제나 환영합니다!

## 문의

프로젝트 관련 문의사항이 있으시면 이슈를 등록해주세요.

