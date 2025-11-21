# Flutter 설치 및 실행 가이드

## Flutter 설치 방법

### 방법 1: Homebrew (macOS, 권장)

```bash
# Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flutter 설치
brew install --cask flutter

# 설치 확인
flutter doctor
```

### 방법 2: 직접 다운로드

1. Flutter 공식 사이트에서 다운로드: https://flutter.dev/docs/get-started/install/macos
2. 압축 해제 후 PATH에 추가:

```bash
# ~/.zshrc 또는 ~/.bash_profile에 추가
export PATH="$PATH:/path/to/flutter/bin"

# 적용
source ~/.zshrc
```

### 방법 3: Git으로 설치

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

## 설치 확인

```bash
flutter doctor
```

필요한 경우 다음을 설치하세요:
- Android Studio (Android 개발용)
- Xcode (iOS 개발용, macOS만)

## 프로젝트 실행

```bash
cd /Users/john/gal/android

# 의존성 설치
flutter pub get

# 사용 가능한 기기 확인
flutter devices

# 앱 실행
flutter run
```

## APK 빌드

```bash
cd /Users/john/gal/android

# Release APK 빌드
flutter build apk --release

# APK 위치
# build/app/outputs/flutter-apk/app-release.apk
```

## 문제 해결

### "command not found: flutter"
- PATH 설정 확인
- 터미널 재시작
- `which flutter`로 설치 위치 확인

### "No devices found"
- Android Studio에서 에뮬레이터 실행
- 또는 실제 안드로이드 기기 연결 (USB 디버깅 활성화)

### 의존성 오류
```bash
flutter clean
flutter pub get
```


