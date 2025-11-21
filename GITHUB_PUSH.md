# GitHub 푸시 가이드

## 현재 상태

✅ Git 저장소 초기화 완료
✅ 파일 커밋 완료 (74개 파일, 7138줄)

## GitHub 저장소 생성 방법

### 방법 1: 웹에서 생성 (권장)

1. **GitHub 접속**: https://github.com/new
2. **저장소 정보 입력**:
   - Repository name: `galmuri-diary` (또는 원하는 이름)
   - Description: `Galmuri Diary - Hybrid Capture & Archiving System`
   - Public 또는 Private 선택
   - **중요**: README, .gitignore, license 추가하지 않기 (이미 있음)
3. **Create repository** 클릭
4. **저장소 URL 복사** (예: `https://github.com/YOUR_USERNAME/galmuri-diary.git`)

### 방법 2: GitHub CLI 사용

```bash
# GitHub CLI 설치 (없는 경우)
brew install gh

# 로그인
gh auth login

# 저장소 생성 및 푸시
cd /Users/john/gal
gh repo create galmuri-diary --public --source=. --remote=origin --push
```

## 푸시 명령어

GitHub 저장소 URL을 받은 후:

```bash
cd /Users/john/gal

# 원격 저장소 추가
git remote add origin https://github.com/YOUR_USERNAME/galmuri-diary.git

# 브랜치 이름을 main으로 설정
git branch -M main

# 푸시
git push -u origin main
```

## 자동 푸시 스크립트

GitHub 저장소 URL을 알려주시면 자동으로 푸시하겠습니다!

예시:
- `https://github.com/username/galmuri-diary.git`
- 또는 `git@github.com:username/galmuri-diary.git`

