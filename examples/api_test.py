#!/usr/bin/env python3
"""
Galmuri Diary API 테스트 스크립트
실제 API를 테스트하는 예제 코드
"""
import requests
import base64
import uuid
from pathlib import Path

# API 설정
BASE_URL = "https://your-app.onrender.com"  # Render URL로 변경
API_KEY = "test_api_key_1234567890"  # 실제 API Key로 변경
USER_ID = str(uuid.uuid4())  # 또는 기존 User ID 사용

headers = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}


def test_health_check():
    """Health Check 테스트"""
    print("=== Health Check ===")
    response = requests.get(f"{BASE_URL}/")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()


def test_capture(image_path: str = None):
    """캡처 API 테스트"""
    print("=== Capture Test ===")
    
    # 테스트 이미지 생성 또는 사용
    if image_path and Path(image_path).exists():
        with open(image_path, "rb") as f:
            image_data = base64.b64encode(f.read()).decode()
    else:
        # 1x1 픽셀 PNG (최소 이미지)
        image_data = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="
    
    payload = {
        "user_id": USER_ID,
        "image_data": image_data,
        "source_url": "https://example.com",
        "page_title": "Python API Test",
        "memo_content": "Python 스크립트로 테스트한 항목",
        "platform": "WEB_EXTENSION"
    }
    
    response = requests.post(
        f"{BASE_URL}/api/capture",
        headers=headers,
        json=payload
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        item = response.json()
        print(f"✅ 저장 성공!")
        print(f"   ID: {item['id']}")
        print(f"   제목: {item['page_title']}")
        print(f"   OCR 상태: {item['ocr_status']}")
        return item['id']
    else:
        print(f"❌ 실패: {response.text}")
        return None


def test_get_items():
    """아이템 목록 조회 테스트"""
    print("=== Get Items ===")
    
    response = requests.get(
        f"{BASE_URL}/api/items/{USER_ID}",
        headers=headers
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        items = response.json()
        print(f"✅ 조회 성공: {len(items)}개 항목")
        for item in items[:3]:  # 처음 3개만 출력
            print(f"   - {item['page_title']} ({item['ocr_status']})")
    else:
        print(f"❌ 실패: {response.text}")
    print()


def test_search(query: str):
    """검색 테스트"""
    print(f"=== Search: '{query}' ===")
    
    payload = {
        "user_id": USER_ID,
        "query": query
    }
    
    response = requests.post(
        f"{BASE_URL}/api/search",
        headers=headers,
        json=payload
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        results = response.json()
        print(f"✅ 검색 성공: {len(results)}개 결과")
        for item in results:
            print(f"   - {item['page_title']}")
    else:
        print(f"❌ 실패: {response.text}")
    print()


def test_get_item(item_id: str):
    """단일 아이템 조회 테스트"""
    print(f"=== Get Item: {item_id} ===")
    
    response = requests.get(
        f"{BASE_URL}/api/item/{item_id}",
        headers=headers
    )
    
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        item = response.json()
        print(f"✅ 조회 성공!")
        print(f"   제목: {item['page_title']}")
        print(f"   메모: {item['memo_content']}")
        print(f"   OCR: {item['ocr_status']}")
    else:
        print(f"❌ 실패: {response.text}")
    print()


def main():
    """메인 테스트 함수"""
    print("=" * 60)
    print("Galmuri Diary API 테스트")
    print("=" * 60)
    print(f"Base URL: {BASE_URL}")
    print(f"User ID: {USER_ID}")
    print()
    
    # 1. Health Check
    test_health_check()
    
    # 2. Capture
    item_id = test_capture()
    
    if item_id:
        # 3. Get Items
        test_get_items()
        
        # 4. Get Item
        test_get_item(item_id)
        
        # 5. Search
        test_search("Python")
        test_search("테스트")
    
    print("=" * 60)
    print("테스트 완료!")
    print("=" * 60)


if __name__ == "__main__":
    # 설정 확인
    if BASE_URL == "https://your-app.onrender.com":
        print("⚠️  BASE_URL을 실제 Render URL로 변경하세요!")
        print("   예: https://galmuri-diary-api.onrender.com")
        print()
    
    main()

