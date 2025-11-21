# 안드로이드 앱 실행 가이드

## 현재 상태

✅ **백엔드 서버**: 실행 중 (http://localhost:8000)
✅ **안드로이드 프로젝트**: 14개 Dart 파일 생성 완료
⚠️ **Flutter**: 설치 필요

## 실행 단계

### 1단계: Flutter 설치

#### macOS에서 설치 (권장)

```bash
# Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flutter 설치
brew install --cask flutter

# 설치 확인
flutter doctor
```

#### 또는 수동 설치

1. https://flutter.dev/docs/get-started/install/macos 방문
2. Flutter SDK 다운로드 및 압축 해제
3. PATH에 추가:
   ```bash
   export PATH="$PATH:/path/to/flutter/bin"
   ```

### 2단계: Android 개발 환경 설정

```bash
# Android Studio 설치 (선택사항, 에뮬레이터 사용 시)
# https://developer.android.com/studio

# 또는 명령줄 도구만 설치
# Android SDK 설치 필요
```

### 3단계: 프로젝트 설정

```bash
cd /Users/john/gal/android

# 의존성 설치
flutter pub get

# 사용 가능한 기기 확인
flutter devices
```

### 4단계: 앱 실행

#### 옵션 A: 에뮬레이터 사용

```bash
# 에뮬레이터 목록 확인
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run
```

#### 옵션 B: 실제 안드로이드 기기 사용

1. 안드로이드 기기에서:
   - 설정 → 개발자 옵션 활성화
   - USB 디버깅 활성화

2. USB로 기기 연결

3. 실행:
   ```bash
   flutter devices  # 기기 확인
   flutter run       # 앱 실행
   ```

### 5단계: APK 빌드 (배포용)

```bash
cd /Users/john/gal/android

# Release APK 빌드
flutter build apk --release

# APK 위치
# build/app/outputs/flutter-apk/app-release.apk
```

## 빠른 실행 (Flutter 설치 후)

```bash
# 1. 백엔드 서버 확인
curl http://localhost:8000

# 2. 안드로이드 프로젝트로 이동
cd /Users/john/gal/android

# 3. 의존성 설치
flutter pub get

# 4. 앱 실행
flutter run
```

## 앱 설정

앱 실행 후:

1. **설정** 화면으로 이동
2. 다음 정보 입력:
   - **API URL**: `http://YOUR_IP:8000` (예: `http://192.168.1.100:8000`)
     - ⚠️ `localhost` 대신 실제 IP 주소 사용 (기기에서 접근 가능하도록)
   - **API Key**: `test_api_key_1234567890` (또는 설정한 키)
   - **User ID**: UUID 형식 (예: `550e8400-e29b-41d4-a716-446655440000`)

3. **저장** 버튼 클릭

## 네트워크 설정

### 로컬 네트워크에서 접근

백엔드 서버가 `localhost:8000`에서 실행 중이라면, 안드로이드 기기에서 접근하려면:

1. **서버 IP 확인**:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```

2. **방화벽 확인**: 포트 8000이 열려있는지 확인

3. **앱에서 사용**: `http://YOUR_IP:8000` 형식으로 입력

### 예시

```bash
# 서버 IP가 192.168.1.100인 경우
# 앱 설정에서 API URL: http://192.168.1.100:8000
```

## 문제 해결

### "command not found: flutter"
- Flutter 설치 확인: `which flutter`
- PATH 설정 확인
- 터미널 재시작

### "No devices found"
- Android Studio에서 에뮬레이터 실행
- 또는 USB로 실제 기기 연결
- `adb devices`로 기기 확인

### "Connection refused" (앱에서 서버 접근 불가)
- 서버가 실행 중인지 확인: `curl http://localhost:8000`
- `localhost` 대신 실제 IP 주소 사용
- 방화벽 설정 확인

### 의존성 오류
```bash
cd /Users/john/gal/android
flutter clean
flutter pub get
```

## 현재 프로젝트 상태

✅ **백엔드**: FastAPI 서버 실행 중
✅ **프로젝트 구조**: Clean Architecture 완료
✅ **Dart 파일**: 14개 파일 생성 완료
✅ **의존성**: pubspec.yaml 설정 완료
⚠️ **Flutter SDK**: 설치 필요

## 다음 단계

1. Flutter 설치 (위 가이드 참조)
2. `flutter pub get` 실행
3. `flutter run` 실행
4. 앱에서 백엔드 서버 연결 설정

---

**참고**: Flutter 설치가 완료되면 `cd /Users/john/gal/android && flutter pub get && flutter run` 명령으로 바로 실행할 수 있습니다!


