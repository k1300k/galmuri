# 📱 APK 다운로드 가이드

## 🎯 현재 상태

✅ **GitHub Actions에서 APK 빌드 성공!**
- 최신 빌드: https://github.com/k1300k/galmuri/actions
- APK는 Artifacts에서 다운로드 가능

---

## 📥 APK 다운로드 방법

### 방법 1: GitHub Actions Artifacts (권장)

1. **GitHub Actions 페이지로 이동**
   ```
   https://github.com/k1300k/galmuri/actions
   ```

2. **최신 성공한 workflow 클릭** (녹색 체크 ✅ 또는 노란색 원 🟡)

3. **페이지 하단으로 스크롤**

4. **Artifacts 섹션**에서 `galmuri-diary-v1.0.0` 찾기

5. **다운로드 버튼 클릭** → `galmuri-diary-v1.0.0.zip` 다운로드

6. **압축 해제** → `app-release.apk` 파일 확인

7. **스마트폰으로 전송하여 설치**

---

### 방법 2: 수동으로 새 빌드 트리거

1. **GitHub Actions 페이지로 이동**
   ```
   https://github.com/k1300k/galmuri/actions
   ```

2. **"Build Android APK" workflow 클릭**

3. **우측 상단 "Run workflow" 버튼 클릭**

4. **Branch: `main` 선택**

5. **"Run workflow" 클릭**

6. **약 3-5분 대기** (빌드 완료까지)

7. **완료된 workflow 클릭** → Artifacts에서 APK 다운로드

---

## 📲 안드로이드 폰에 설치하는 방법

### 1단계: APK 파일 전송

**방법 A**: 스마트폰 브라우저에서 직접 다운로드
- 스마트폰 브라우저에서 GitHub Actions 페이지 접속
- Artifacts에서 직접 다운로드

**방법 B**: 컴퓨터에서 다운로드 후 전송
- AirDrop (Mac → Android는 제한적)
- Google Drive / Dropbox
- USB 케이블로 전송
- 이메일 첨부

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

## 🎉 설치 후 테스트

### 주요 기능 테스트:

1. **앱 실행**
   - "갈무리 다이어리" 앱 아이콘 클릭

2. **설정 확인**
   - 우측 상단 설정 아이콘 클릭
   - API URL 확인: `https://galmuri.onrender.com`
   - 필요시 API Key 입력

3. **캡처 기능 테스트**
   - 하단 **"캡처"** 탭 클릭
   - **"화면 캡처"** 버튼 클릭 (안드로이드 전용!)
   - 또는 **"갤러리"** / **"카메라"** 버튼으로 이미지 선택

4. **저장 및 확인**
   - 제목/메모 입력
   - 저장 버튼 클릭
   - 홈 화면에서 저장된 항목 확인

5. **검색 기능**
   - 우측 상단 검색 아이콘 클릭
   - 키워드로 검색 테스트

---

## 🔄 새 버전 빌드가 필요한 경우

### 자동 빌드 (코드 변경 시)
- `android/` 디렉토리 변경사항을 `main` 브랜치에 푸시하면 자동으로 빌드 시작

### 수동 빌드
- GitHub Actions에서 "Run workflow" 버튼으로 수동 실행

---

## 📊 APK 정보

- **앱 이름**: 갈무리 다이어리 (Galmuri Diary)
- **패키지명**: com.galmuri.diary
- **버전**: 1.0.0+1
- **최소 Android 버전**: Android 5.0 (API 21)
- **타겟 Android 버전**: Android 14 (API 35)

---

## ❓ 문제 해결

### "알 수 없는 소스에서 설치할 수 없습니다"
- 설정 → 보안 → 알 수 없는 소스 허용

### "앱이 설치되지 않았습니다"
- 이전 버전 삭제 후 재설치
- 저장 공간 확인

### "APK를 찾을 수 없습니다"
- GitHub Actions에서 최신 빌드 확인
- Artifacts 섹션에서 다운로드

---

## 🎯 빠른 다운로드 링크

**GitHub Actions**: https://github.com/k1300k/galmuri/actions

**최신 빌드 Artifacts**에서 `galmuri-diary-v1.0.0.zip` 다운로드!

