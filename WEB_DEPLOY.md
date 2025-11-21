# Flutter Web 프론트엔드 배포 가이드

## Flutter Web이란?

Flutter Web은 Flutter로 만든 앱을 웹 브라우저에서 실행할 수 있게 해주는 기능입니다.

## 현재 구조

```
┌─────────────────────────┐
│  Flutter Web            │ ← 웹 프론트엔드 (Vercel/Netlify)
│  (사용자 인터페이스)     │
└─────────────────────────┘
          ↓ API 호출
┌─────────────────────────┐
│  FastAPI 백엔드          │ ← 서비스 (Render)
│  https://galmuri.onrender.com │
└─────────────────────────┘
```

## ✅ Render 백엔드 연동

웹 프론트엔드는 기본적으로 **https://galmuri.onrender.com** 백엔드와 연동됩니다.

- 기본 API URL: `https://galmuri.onrender.com`
- 설정 화면에서 변경 가능

## Flutter Web 빌드

### 1단계: 웹 빌드

```bash
cd android

# 웹 빌드
flutter build web

# 빌드 결과물 위치
# build/web/
```

### 2단계: 빌드 확인

```bash
# 로컬에서 테스트
flutter run -d chrome
```

## 배포 방법

### 방법 1: Vercel 배포 (권장) ⭐

#### Step 1: Vercel CLI 설치

```bash
npm i -g vercel
```

#### Step 2: 배포

```bash
cd android
flutter build web
cd build/web

# Vercel 배포
vercel

# 또는 프로젝트 루트에서
vercel --cwd android/build/web
```

#### Step 3: vercel.json 설정 (선택사항)

프로젝트 루트에 `vercel.json` 생성:

```json
{
  "buildCommand": "cd android && flutter build web",
  "outputDirectory": "android/build/web",
  "framework": null
}
```

### 방법 2: Netlify 배포

#### Step 1: Netlify CLI 설치

```bash
npm i -g netlify-cli
```

#### Step 2: 배포

```bash
cd android
flutter build web

# Netlify 배포
netlify deploy --prod --dir=build/web
```

#### Step 3: netlify.toml 설정

프로젝트 루트에 `netlify.toml` 생성:

```toml
[build]
  command = "cd android && flutter build web"
  publish = "android/build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 방법 3: GitHub Pages 배포

#### Step 1: 웹 빌드

```bash
cd android
flutter build web --base-href "/galmuri/"
```

#### Step 2: GitHub Actions 설정

`.github/workflows/deploy-web.yml` 생성:

```yaml
name: Deploy Flutter Web

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.3'
      - run: cd android && flutter pub get
      - run: cd android && flutter build web --base-href "/galmuri/"
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: android/build/web
```

## 웹 앱 설정

### API URL 설정

웹 앱은 기본적으로 **https://galmuri.onrender.com** 백엔드와 연동됩니다.

1. **앱 실행**
2. **설정 화면**으로 이동
3. **API URL 확인**: `https://galmuri.onrender.com` (기본값)
4. **API Key 입력**: Render 백엔드에서 설정한 API Key
5. **User ID 입력**: UUID 형식의 사용자 ID
6. **저장**

### 환경 변수 (빌드 시)

빌드 시 API URL을 하드코딩할 수도 있습니다:

`android/lib/config.dart` 생성:

```dart
class AppConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://your-app.onrender.com',
  );
  
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
}
```

빌드 시:

```bash
flutter build web --dart-define=API_URL=https://your-app.onrender.com
```

## 웹 전용 기능

### 파일 업로드

웹에서는 `html.FileUploadInputElement`를 사용합니다:

```dart
import 'dart:html' as html;

final input = html.FileUploadInputElement()..accept = 'image/*';
input.click();
```

### 로컬 저장소

웹에서는 IndexedDB 또는 LocalStorage를 사용합니다.

## 배포 후 확인

### 1. 웹 앱 접속

배포된 URL로 접속:
- Vercel: `https://your-app.vercel.app`
- Netlify: `https://your-app.netlify.app`

### 2. 설정 확인

1. 설정 화면에서 API URL 입력
2. 백엔드 서버 연결 확인

### 3. 기능 테스트

1. 이미지 업로드 테스트
2. 저장 테스트
3. 검색 테스트

## 문제 해결

### CORS 오류

백엔드에서 CORS 설정 확인:

```python
# backend/presentation/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-web-app.vercel.app",
        "https://your-web-app.netlify.app",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 파일 업로드 실패

- 파일 크기 제한 확인
- Base64 인코딩 확인

### API 연결 실패

- API URL 확인
- CORS 설정 확인
- 네트워크 탭에서 요청 확인

## 빠른 배포 (Vercel)

```bash
# 1. 빌드
cd android
flutter build web

# 2. 배포
cd build/web
vercel

# 3. 완료!
```

## 현재 상태

- ✅ Flutter Web 코드 준비됨
- ✅ 웹 최적화 UI (`web_home_screen.dart`)
- ✅ 파일 업로드 지원 (웹)
- ⏳ 배포 필요 (Vercel/Netlify)

## 다음 단계

1. `flutter build web` 실행
2. Vercel 또는 Netlify에 배포
3. 백엔드 API URL 설정
4. 테스트

