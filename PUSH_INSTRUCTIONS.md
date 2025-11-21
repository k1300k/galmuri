# GitHub 푸시 방법

## 현재 상태

✅ Git 저장소 초기화 완료
✅ 커밋 완료 (74개 파일, 7138줄)
✅ 원격 저장소 설정 완료: https://github.com/k1300k/galmuri.git

## 푸시 방법

### 방법 1: Personal Access Token 사용 (권장)

1. **Personal Access Token 생성**
   - https://github.com/settings/tokens 접속
   - "Generate new token (classic)" 클릭
   - Note: `galmuri-diary-push` (임의의 이름)
   - Expiration: 원하는 기간 선택
   - **Scopes**: `repo` 체크 (모든 권한)
   - "Generate token" 클릭
   - **토큰 복사** (한 번만 표시됨!)

2. **푸시 실행**
   ```bash
   cd /Users/john/gal
   git push -u origin main
   ```
   
   - Username: `k1300k`
   - Password: **복사한 토큰** 입력

### 방법 2: GitHub CLI 사용

```bash
# GitHub CLI 설치
brew install gh

# 로그인
gh auth login

# 푸시
cd /Users/john/gal
git push -u origin main
```

### 방법 3: SSH 키 설정 (장기적)

```bash
# SSH 키 생성 (없는 경우)
ssh-keygen -t ed25519 -C "your_email@example.com"

# SSH 키를 GitHub에 추가
cat ~/.ssh/id_ed25519.pub
# 위 내용을 https://github.com/settings/keys 에 추가

# 원격 저장소를 SSH로 변경
cd /Users/john/gal
git remote set-url origin git@github.com:k1300k/galmuri.git

# 푸시
git push -u origin main
```

## 확인

푸시 성공 후:
- https://github.com/k1300k/galmuri 접속
- 모든 파일이 업로드되었는지 확인

## 문제 해결

### "Authentication failed"
- Personal Access Token이 올바른지 확인
- `repo` 권한이 있는지 확인

### "Repository not found"
- 저장소가 존재하는지 확인
- 접근 권한이 있는지 확인

### "Permission denied"
- SSH 키가 GitHub에 추가되었는지 확인
- 또는 Personal Access Token 사용

