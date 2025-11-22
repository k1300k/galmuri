# Galmuri Diary Android App

안드로이드용 Galmuri Diary 앱입니다. Flutter로 구현되어 있으며, 기존 백엔드 API와 완벽하게 통합됩니다.

## 주요 기능

- 📸 **다른 앱 화면 캡처**: MediaProjection API를 사용한 실시간 화면 캡처
  - 🎯 **오버레이 캡처 버튼**: 다른 앱 위에 표시되는 떠있는 버튼
  - 🖱️ **드래그 가능**: 버튼을 원하는 위치로 이동 가능
  - 💾 **자동 저장**: 캡처 후 즉시 자동 저장 (제목 자동 생성)
  - 🔄 **위치 기억**: 마지막 버튼 위치를 기억하여 다음에도 같은 위치에 표시
  - 🛡️ **Android 14 지원**: 최신 보안 정책을 준수하여 안정적인 동작 보장
- 💾 **Local First**: SQLite 로컬 DB에 우선 저장, 오프라인 작동
- 🔄 **자동 동기화**: 백그라운드에서 서버와 동기화
- 🔍 **검색**: 제목, 메모, OCR 텍스트 검색
- 📝 **메모 추가**: 각 캡처에 메모 추가 가능 (선택사항)

## 기술 스택

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Architecture**: Clean Architecture
- **Local DB**: SQLite (sqflite)
- **HTTP**: Dio
- **State Management**: Provider / Riverpod
- **Image Processing**: image_picker, screenshot

## 프로젝트 구조

```
android/
├── lib/
│   ├── domain/              # Domain Layer
│   │   ├── entities/       # GalmuriItem 엔티티
│   │   └── repositories/   # Repository 인터페이스
│   ├── data/               # Data Layer
│   │   ├── models/         # 데이터 모델
│   │   ├── repositories/   # Repository 구현체
│   │   ├── datasources/    # 로컬/원격 데이터소스
│   │   └── api/            # API 클라이언트
│   └── presentation/       # Presentation Layer
│       ├── screens/        # 화면
│       ├── widgets/        # 재사용 가능한 위젯
│       └── providers/      # 상태 관리
├── android/                # Android 네이티브 설정
├── pubspec.yaml            # Flutter 의존성
└── README.md
```

## 시작하기

### 1. Flutter 설치

```bash
# Flutter 설치 확인
flutter --version

# Flutter가 없다면 설치
# macOS:
brew install --cask flutter
```

### 2. 프로젝트 설정

```bash
cd android
flutter pub get
```

### 3. 실행

```bash
# Android 에뮬레이터 또는 실제 기기 연결 후
flutter run

# 또는 APK 빌드
flutter build apk --release
```

## 백엔드 연결

앱 설정에서 백엔드 API URL을 설정해야 합니다:

```
API URL: http://YOUR_SERVER_IP:8000
API Key: your_api_key
User ID: your_user_id
```

## 사용 방법

### 간단한 화면 캡처 (3단계)

1. **홈 화면에서 "캡처" 버튼 클릭**
   - 권한이 없으면 자동으로 요청 (최초 1회)
   - 오버레이 권한 허용
   - 화면 캡처 권한 허용

2. **다른 앱으로 이동**
   - 화면 상단에 빨간색 "화면 캡처" 버튼 표시
   - 버튼을 드래그하여 원하는 위치로 이동 가능

3. **"화면 캡처" 버튼 클릭**
   - 현재 화면이 자동으로 캡처됨
   - 자동으로 저장됨 (제목: "화면 캡처 YYYY-MM-DD HH:MM")
   - 완료!

### 주요 화면

1. **홈 화면**: 최근 캡처 목록
2. **캡처 화면**: 이미지 업로드 또는 수동 입력
3. **검색 화면**: 저장된 항목 검색
4. **설정 화면**: API 설정, 동기화 관리

## APK 빌드

```bash
# Release APK 빌드
flutter build apk --release

# APK 위치: build/app/outputs/flutter-apk/app-release.apk
```

## 개발 가이드

### Clean Architecture

- **Domain**: 비즈니스 로직, 엔티티 (프레임워크 독립적)
- **Data**: 데이터 소스, Repository 구현체
- **Presentation**: UI, 상태 관리

### Local First 전략

1. 모든 데이터는 먼저 로컬 SQLite에 저장
2. 백그라운드에서 서버와 동기화
3. 오프라인에서도 모든 기능 사용 가능


