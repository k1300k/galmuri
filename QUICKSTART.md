# Galmuri Diary - 빠른 시작 가이드 🚀

이 가이드를 따라하면 5분 안에 Galmuri Diary를 실행할 수 있습니다.

## 준비 사항

- Python 3.11 이상
- Chrome 또는 Whale 브라우저
- (선택) Tesseract OCR

## 1단계: 설치

### 자동 설치 (권장)

```bash
cd gal
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 수동 설치

```bash
# 1. 백엔드 의존성 설치
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# 2. Tesseract 설치 (선택사항 - OCR 사용 시)
# macOS:
brew install tesseract tesseract-lang

# Ubuntu/Debian:
sudo apt-get install tesseract-ocr tesseract-ocr-kor

# 3. 아이콘 생성 (선택사항)
cd ..
python3 scripts/create_icons.py
```

## 2단계: 백엔드 서버 실행

```bash
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate
python run.py
```

**실행 확인:**
- 브라우저에서 http://localhost:8000 접속
- "running" 상태 확인
- API 문서: http://localhost:8000/docs

## 3단계: Chrome Extension 설치

1. Chrome에서 `chrome://extensions/` 열기
2. 우측 상단 "개발자 모드" ON
3. "압축해제된 확장 프로그램을 로드합니다" 클릭
4. `gal/extension` 폴더 선택
5. 확장 프로그램 목록에 "Galmuri Diary" 표시 확인

## 4단계: Extension 설정

### User ID 생성

먼저 UUID 형식의 User ID가 필요합니다:

```bash
# Python으로 생성
python3 -c "import uuid; print(uuid.uuid4())"
```

또는 온라인 도구 사용: https://www.uuidgenerator.net/

### 설정 입력

1. Extension 아이콘 클릭
2. "설정" 탭 선택
3. 다음 정보 입력:

```
API Key: my_secret_key_1234567890
User ID: (위에서 생성한 UUID)
API URL: http://localhost:8000
```

4. "설정 저장" 클릭

## 5단계: 첫 캡처!

1. 아무 웹 페이지로 이동 (예: https://news.ycombinator.com)
2. Extension 아이콘 클릭
3. 현재 페이지가 자동으로 캡처됩니다
4. 메모 입력 (선택사항): "해커뉴스 메인페이지"
5. "저장" 클릭

✅ 성공 메시지가 표시되고 자동으로 닫힙니다!

## 6단계: 저장된 항목 확인

### API로 확인

```bash
# 내 아이템 목록 조회
curl -H "X-API-Key: my_secret_key_1234567890" \
  http://localhost:8000/api/items/YOUR_USER_ID

# 검색 테스트
curl -X POST \
  -H "X-API-Key: my_secret_key_1234567890" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "YOUR_USER_ID", "query": "해커뉴스"}' \
  http://localhost:8000/api/search
```

### Swagger UI로 확인

http://localhost:8000/docs 에서 시각적으로 API 테스트 가능

## 테스트 실행 (개발자용)

```bash
cd backend
source venv/bin/activate
pytest tests/ -v
```

## 문제 해결

### 1. "Tesseract is not installed" 경고

**현상**: 서버는 실행되지만 OCR이 작동하지 않음

**해결**: 
```bash
# macOS
brew install tesseract tesseract-lang

# Ubuntu
sudo apt-get install tesseract-ocr tesseract-ocr-kor tesseract-ocr-eng
```

**임시 대응**: OCR 없이도 기본 기능은 모두 사용 가능합니다.

### 2. Extension에서 "저장 실패" 에러

**확인사항**:
- [ ] 백엔드 서버가 실행 중인가?
- [ ] API URL이 `http://localhost:8000`인가?
- [ ] API Key가 10자 이상인가?
- [ ] User ID가 UUID 형식인가?

**해결**:
```bash
# 서버 상태 확인
curl http://localhost:8000
```

### 3. CORS 에러

**현상**: Console에 CORS 관련 에러

**해결**: `backend/presentation/main.py`에서 CORS 설정 확인

### 4. 아이콘이 표시되지 않음

**임시 대응**: 아이콘 없이도 Extension은 작동합니다.

**해결**: 
```bash
cd gal
# backend venv에서 실행
source backend/venv/bin/activate
pip install pillow
python3 scripts/create_icons.py
```

## 다음 단계

### 검색 기능 활용

OCR이 설치되어 있다면, 이미지 내 텍스트도 검색됩니다:

```bash
# "배민"이라는 텍스트가 스크린샷에 있는 항목 찾기
curl -X POST \
  -H "X-API-Key: your_key" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "YOUR_USER_ID", "query": "배민"}' \
  http://localhost:8000/api/search
```

### 웹 UI 개발 (향후 계획)

현재는 Extension과 API만 제공됩니다. 웹 UI를 개발하면:
- 저장된 모든 캡처 보기
- 그리드/리스트 뷰
- 태그 관리
- 공유 기능

### 모바일 앱 (향후 계획)

iOS/Android 앱에서도 스크린샷을 저장하고 동기화할 수 있습니다.

## 개발 모드

### 서버 자동 재시작

```bash
cd backend
source venv/bin/activate
python run.py  # 파일 변경 시 자동 재시작
```

### Extension 디버깅

1. `chrome://extensions/` 에서 "백그라운드 페이지" 클릭
2. Console에서 로그 확인
3. 코드 수정 후 새로고침 버튼 클릭

## 도움이 필요하신가요?

- 📚 [전체 문서](README.md)
- 🐛 [이슈 등록](https://github.com/your-repo/issues)
- 💬 [Discussions](https://github.com/your-repo/discussions)

---

즐거운 갈무리 되세요! 📚✨


