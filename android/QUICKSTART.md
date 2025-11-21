# Android App 빠른 시작 가이드

## 1. Flutter 설치

```bash
# macOS
brew install --cask flutter

# 설치 확인
flutter doctor
```

## 2. 프로젝트 설정

```bash
cd android
flutter pub get
```

## 3. 앱 실행

### 에뮬레이터 사용

```bash
# 에뮬레이터 목록 확인
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run
```

### 실제 기기 사용

1. 안드로이드 기기에서 "개발자 옵션" 활성화
2. "USB 디버깅" 활성화
3. USB로 기기 연결
4. 기기 확인: `flutter devices`
5. 앱 실행: `flutter run`

## 4. APK 빌드

```bash
# Release APK 빌드
flutter build apk --release

# APK 위치
# build/app/outputs/flutter-apk/app-release.apk
```

## 5. 앱 설정

앱을 실행한 후:

1. **설정** 화면으로 이동
2. 다음 정보 입력:
   - **API URL**: `http://YOUR_SERVER_IP:8000` (예: `http://192.168.1.100:8000`)
   - **API Key**: 백엔드에서 사용하는 API Key
   - **User ID**: UUID 형식의 사용자 ID

3. **저장** 버튼 클릭

## 6. 사용하기

1. **홈 화면**: 저장된 캡처 목록 확인
2. **캡처 버튼**: 새 이미지 캡처
   - 갤러리에서 선택
   - 카메라로 촬영
3. **검색**: 저장된 항목 검색
4. **동기화**: 서버와 데이터 동기화

## 문제 해결

### "No devices found"

- USB 디버깅이 활성화되어 있는지 확인
- `adb devices`로 기기 연결 확인
- USB 드라이버 설치 확인

### 빌드 에러

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### 네트워크 연결 실패

- API URL이 올바른지 확인 (localhost 대신 실제 IP 사용)
- 방화벽 설정 확인
- 백엔드 서버가 실행 중인지 확인

## 다음 단계

- [BUILD.md](BUILD.md) - 상세 빌드 가이드
- [README.md](../README.md) - 전체 프로젝트 문서


