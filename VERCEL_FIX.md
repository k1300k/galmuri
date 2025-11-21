# Vercel 배포 오류 해결 가이드

## 문제 상황

```
500: INTERNAL_SERVER_ERROR
Code: FUNCTION_INVOCATION_FAILED
```

Flutter 웹 앱을 Vercel에 배포할 때 서버리스 함수 오류가 발생하는 경우가 있습니다.

## 원인

1. **Flutter 웹은 정적 파일**: Flutter 웹 앱은 서버리스 함수가 필요 없는 정적 파일입니다.
2. **잘못된 빌드 설정**: Vercel이 Flutter 빌드를 제대로 인식하지 못할 수 있습니다.
3. **경로 문제**: SPA 라우팅을 위한 rewrites 설정이 필요합니다.

## 해결 방법

### 방법 1: 프로젝트 루트에 vercel.json 추가 (권장)

프로젝트 루트에 `vercel.json` 파일을 생성하세요:

```json
{
  "buildCommand": "cd android && flutter pub get && flutter build web --release",
  "outputDirectory": "android/build/web",
  "framework": null,
  "installCommand": "cd android && flutter pub get",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### 방법 2: Vercel 대시보드에서 설정

1. Vercel 대시보드 → 프로젝트 설정
2. **Build & Development Settings**:
   - **Framework Preset**: Other
   - **Build Command**: `cd android && flutter pub get && flutter build web --release`
   - **Output Directory**: `android/build/web`
   - **Install Command**: `cd android && flutter pub get`

3. **Settings** → **Environment Variables**:
   - Flutter 경로가 필요하면 추가

### 방법 3: 수동 배포 (빌드 후 업로드)

```bash
# 1. 로컬에서 빌드
cd android
flutter pub get
flutter build web --release

# 2. Vercel CLI로 배포
cd build/web
vercel --prod
```

## Flutter 설치 확인

Vercel 빌드 환경에 Flutter가 설치되어 있지 않을 수 있습니다.

### 해결책: GitHub Actions로 빌드 후 Vercel 배포

`.github/workflows/deploy-vercel.yml`:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.3'
      
      - name: Build Flutter Web
        run: |
          cd android
          flutter pub get
          flutter build web --release
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: android/build/web
```

## 빠른 해결 (권장)

### Step 1: 프로젝트 루트에 vercel.json 생성

```bash
# 프로젝트 루트에서
cat > vercel.json << 'EOF'
{
  "buildCommand": "cd android && flutter pub get && flutter build web --release",
  "outputDirectory": "android/build/web",
  "framework": null,
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
EOF
```

### Step 2: Git에 커밋 및 푸시

```bash
git add vercel.json
git commit -m "fix: Vercel 배포 설정 수정"
git push origin main
```

### Step 3: Vercel에서 재배포

Vercel 대시보드에서:
1. 프로젝트 선택
2. **Deployments** 탭
3. 최신 배포의 **Redeploy** 클릭

## 대안: Netlify 사용

Vercel에서 계속 문제가 발생하면 Netlify를 사용할 수 있습니다:

```bash
cd android
flutter build web --release
netlify deploy --prod --dir=build/web
```

Netlify는 Flutter 웹 앱을 더 잘 지원합니다.

## 확인 사항

1. ✅ `vercel.json`이 프로젝트 루트에 있는가?
2. ✅ `outputDirectory`가 올바른가? (`android/build/web`)
3. ✅ `rewrites` 설정이 있는가? (SPA 라우팅)
4. ✅ Flutter가 빌드 환경에 설치되어 있는가?

## 추가 리소스

- [Vercel Documentation](https://vercel.com/docs)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

