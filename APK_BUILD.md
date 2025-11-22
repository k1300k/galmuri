# 📱 Android APK 자동 빌드 가이드

## 🚀 GitHub Actions를 통한 자동 빌드

### 빌드가 자동으로 실행되는 경우
1. `main` 브랜치에 푸시할 때 (`android/` 디렉토리 변경 시)
2. GitHub에서 수동으로 실행할 때

---

## 📥 APK 다운로드 방법

### 방법 1: GitHub Actions Artifacts (권장)

1. **GitHub 저장소로 이동**
   ```
   https://github.com/k1300k/galmuri
   ```

2. **Actions 탭 클릭**

3. **최신 "Build Android APK" workflow 클릭**

4. **Artifacts 섹션에서 다운로드**
   - `galmuri-diary-v1.0.0.zip` 파일 다운로드
   - ZIP 압축 해제
   - `app-release.apk` 파일 확인

5. **스마트폰으로 전송**
   - AirDrop (Mac → iPhone 불가, Android만 가능)
   - Google Drive / Dropbox
   - 이메일 첨부
   - USB 케이블

---

### 방법 2: GitHub Releases (자동 생성)

1. **GitHub 저장소의 Releases 페이지로 이동**
   ```
   https://github.com/k1300k/galmuri/releases
   ```

2. **최신 릴리즈 선택**

3. **Assets에서 `app-release.apk` 다운로드**

4. **스마트폰에 설치**

---

## 📲 안드로이드 폰에 설치하는 방법

### 1단계: APK 파일 전송
- **방법 A**: 스마트폰 브라우저에서 GitHub Releases에서 직접 다운로드
- **방법 B**: 컴퓨터에서 다운로드 후 USB로 전송
- **방법 C**: Google Drive/Dropbox 등 클라우드 저장소 이용

### 2단계: 설치 허용 설정
1. 안드로이드 **설정** → **보안** (또는 **앱**)
2. **알 수 없는 소스** (또는 **앱 설치**) 활성화
3. 설치하려는 앱 (Chrome, 파일 관리자 등)에 대해 허용

### 3단계: APK 설치
1. 파일 관리자 또는 다운로드 폴더에서 `app-release.apk` 찾기
2. 파일 탭하여 설치 시작
3. **설치** 버튼 클릭
4. 설치 완료!

---

## 🔄 수동으로 빌드 실행하기

GitHub Actions를 수동으로 트리거하려면:

1. **GitHub 저장소로 이동**
   ```
   https://github.com/k1300k/galmuri
   ```

2. **Actions 탭 클릭**

3. **"Build Android APK" workflow 선택**

4. **"Run workflow" 버튼 클릭**
   - Branch: `main` 선택
   - **"Run workflow"** 클릭

5. **빌드 진행 상황 확인**
   - 약 3-5분 소요
   - 완료되면 녹색 체크 표시

6. **APK 다운로드**
   - Artifacts 또는 Releases에서 다운로드

---

## 🔧 로컬에서 빌드하려면 (선택사항)

GitHub Actions 대신 로컬에서 빌드하려면 Android SDK가 필요합니다:

```bash
# Android Studio 설치
brew install --cask android-studio

# 환경 변수 설정
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc

# APK 빌드
cd /Users/john/gal/android
flutter build apk --release
```

---

## 📊 버전 관리

APK 버전은 `android/pubspec.yaml`에서 관리됩니다:

```yaml
version: 1.0.0+1
#        ^^^ ^^^
#        |   |
#        |   +-- Build number (자동 증가)
#        +------ Version name (수동 관리)
```

버전을 업데이트하려면:
```bash
# pubspec.yaml 수정
version: 1.0.1+2

# GitHub에 푸시
git add android/pubspec.yaml
git commit -m "Bump version to 1.0.1"
git push origin main
```

---

## ❓ 문제 해결

### "알 수 없는 소스에서 설치할 수 없습니다"
- 설정 → 보안 → 알 수 없는 소스 허용

### "앱이 설치되지 않았습니다"
- 이전 버전 삭제 후 재설치
- 저장 공간 확인

### GitHub Actions 빌드 실패
1. Actions 탭에서 실패한 workflow 클릭
2. 로그 확인
3. 문제 수정 후 다시 푸시

---

## 🎉 빌드 완료 후

APK 설치 후:
1. **앱 실행**
2. **설정**에서 API URL 확인: `https://galmuri.onrender.com`
3. **캡처** 탭에서 **화면 캡처** 버튼으로 스크린샷 촬영
4. 제목/메모 입력 후 저장
5. 홈 화면에서 저장된 항목 확인

---

## 🌐 웹 버전

Android 앱 외에 웹 버전도 사용 가능합니다:
- **웹 URL**: https://web-h128bo4mo-johns-projects-38f16458.vercel.app
- **참고**: 웹 버전에는 "화면 캡처" 기능이 없습니다 (안드로이드 앱 전용)

