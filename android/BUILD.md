# Galmuri Diary Android - APK 빌드 가이드

## 사전 요구사항

1. **Flutter 설치**
   ```bash
   # macOS
   brew install --cask flutter
   
   # 또는 공식 사이트에서 다운로드
   # https://flutter.dev/docs/get-started/install
   ```

2. **Android Studio 설치**
   - Android Studio 다운로드: https://developer.android.com/studio
   - Android SDK 설치
   - Android 에뮬레이터 설정 (선택사항)

3. **Flutter 설정 확인**
   ```bash
   flutter doctor
   ```

## 프로젝트 설정

```bash
cd android
flutter pub get
```

## APK 빌드

### Debug APK (개발용)

```bash
flutter build apk --debug
```

**출력 위치**: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (배포용)

```bash
flutter build apk --release
```

**출력 위치**: `build/app/outputs/flutter-apk/app-release.apk`

### Split APK (용량 최적화)

```bash
# 32-bit와 64-bit 분리
flutter build apk --split-per-abi
```

**출력 위치**:
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit)
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (x86_64)

## 앱 번들 (AAB) 빌드 (Google Play 배포용)

```bash
flutter build appbundle --release
```

**출력 위치**: `build/app/outputs/bundle/release/app-release.aab`

## APK 설치

### ADB를 통한 설치

```bash
# 기기 연결 확인
adb devices

# APK 설치
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 직접 설치

1. APK 파일을 안드로이드 기기로 전송
2. 기기에서 "알 수 없는 출처" 설치 허용
3. APK 파일 클릭하여 설치

## 서명 설정 (Release 빌드)

### 1. 키스토어 생성

```bash
keytool -genkey -v -keystore ~/galmuri-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias galmuri
```

### 2. key.properties 파일 생성

`android/key.properties` 파일 생성:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=galmuri
storeFile=/Users/your_username/galmuri-key.jks
```

### 3. build.gradle 수정

`android/app/build.gradle`에 서명 설정 추가 (이미 포함되어 있을 수 있음)

## 문제 해결

### 빌드 에러: "Gradle sync failed"

```bash
cd android
./gradlew clean
flutter clean
flutter pub get
flutter build apk --release
```

### 메모리 부족 에러

`android/gradle.properties`에 추가:

```properties
org.gradle.jvmargs=-Xmx4096m
```

### ProGuard/R8 에러

`android/app/proguard-rules.pro` 파일 확인 및 규칙 추가

## 배포 체크리스트

- [ ] 앱 아이콘 설정
- [ ] 앱 이름 확인
- [ ] 버전 코드/이름 확인
- [ ] 서명 키스토어 설정
- [ ] ProGuard 규칙 확인
- [ ] 테스트 빌드 확인
- [ ] Google Play Console 설정 (배포 시)

## 추가 리소스

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Android 앱 배포 가이드](https://developer.android.com/studio/publish)
- [Google Play Console](https://play.google.com/console)


