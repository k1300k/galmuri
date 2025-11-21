# Flutter Web 프론트엔드 빠른 시작

## ✅ 빌드 완료

Flutter Web 프론트엔드가 성공적으로 빌드되었습니다!

```
✓ Built build/web
```

## 🚀 배포 방법

### 방법 1: Vercel 배포 (권장)

```bash
# 1. Vercel CLI 설치
npm i -g vercel

# 2. 배포
cd android/build/web
vercel

# 또는 프로젝트 루트에서
vercel --cwd android/build/web
```

### 방법 2: Netlify 배포

```bash
# 1. Netlify CLI 설치
npm i -g netlify-cli

# 2. 배포
cd android
netlify deploy --prod --dir=build/web
```

## 🔗 Render 백엔드 연동

웹 프론트엔드는 **https://galmuri.onrender.com** 백엔드와 자동으로 연동됩니다.

### 설정 방법

1. 웹 앱 실행
2. **설정** 화면으로 이동
3. 다음 정보 입력:
   - **API URL**: `https://galmuri.onrender.com` (기본값)
   - **API Key**: Render 백엔드에서 설정한 API Key
   - **User ID**: UUID 형식의 사용자 ID
4. **저장** 버튼 클릭

## 📱 사용 방법

1. **홈 화면**: 저장된 캡처 목록 확인
2. **캡처 버튼**: 새 이미지 업로드
   - 갤러리에서 선택
   - 웹에서는 파일 선택 다이얼로그 사용
3. **검색**: 저장된 항목 검색
4. **설정**: API 설정 및 동기화 관리

## 🧪 로컬 테스트

```bash
cd android
flutter run -d chrome
```

## 📦 빌드 결과물

빌드된 파일 위치:
```
android/build/web/
```

이 폴더를 Vercel, Netlify, 또는 다른 정적 호스팅 서비스에 배포하면 됩니다.

## 🔧 문제 해결

### CORS 오류

Render 백엔드에서 CORS 설정 확인:
- `backend/presentation/main.py`에서 `allow_origins`에 웹 프론트엔드 URL 추가

### API 연결 실패

1. API URL 확인: `https://galmuri.onrender.com`
2. API Key 확인
3. 네트워크 탭에서 요청 확인

## 📚 더 자세한 정보

- [WEB_DEPLOY.md](WEB_DEPLOY.md) - 상세 배포 가이드
- [API_USAGE.md](API_USAGE.md) - API 사용 가이드

