# Flutter 설치 가이드

## 방법 1: Homebrew 설치 (권장, 수동 실행 필요)

터미널에서 다음 명령을 **직접 실행**해주세요:

```bash
# 1. Homebrew 설치 (sudo 권한 필요)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Homebrew PATH 추가 (설치 후 안내되는 명령 실행)
# 예시:
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Flutter 설치
brew install --cask flutter

# 4. 설치 확인
flutter doctor
```

## 방법 2: Flutter 직접 다운로드 (권한 없이 가능)

### macOS용 설치

1. **Flutter SDK 다운로드**:
   ```bash
   cd ~
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. **PATH에 추가**:
   ```bash
   # ~/.zshrc 파일 편집
   nano ~/.zshrc
   
   # 다음 줄 추가:
   export PATH="$PATH:$HOME/flutter/bin"
   
   # 저장 후 적용
   source ~/.zshrc
   ```

3. **설치 확인**:
   ```bash
   flutter doctor
   ```

## 방법 3: 공식 사이트에서 다운로드

1. https://flutter.dev/docs/get-started/install/macos 방문
2. Flutter SDK 다운로드 (ZIP 파일)
3. 압축 해제 (예: `~/flutter` 폴더)
4. PATH에 추가:
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```

## 설치 후 확인

```bash
# Flutter 버전 확인
flutter --version

# 개발 환경 확인
flutter doctor

# 필요한 경우 추가 도구 설치
flutter doctor --android-licenses  # Android 라이선스 동의
```

## 프로젝트 실행

Flutter 설치가 완료되면:

```bash
cd /Users/john/gal/android

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 문제 해결

### "command not found: flutter"
- PATH 설정 확인: `echo $PATH`
- 터미널 재시작
- `which flutter`로 설치 위치 확인

### "Android toolchain" 오류
- Android Studio 설치 또는 Android SDK만 설치
- `flutter doctor`에서 안내하는 명령 실행

### 권한 오류
- Homebrew 설치 시 sudo 권한 필요
- 또는 방법 2 (직접 다운로드) 사용

## 빠른 체크리스트

- [ ] Flutter 설치
- [ ] `flutter doctor` 실행하여 환경 확인
- [ ] Android Studio 또는 Android SDK 설치 (선택사항)
- [ ] `cd /Users/john/gal/android && flutter pub get`
- [ ] `flutter run` 실행

---

**참고**: Homebrew 설치에 sudo 권한이 필요한 경우, 터미널에서 직접 실행하거나 방법 2(직접 다운로드)를 사용하세요.


