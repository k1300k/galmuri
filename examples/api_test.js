/**
 * Galmuri Diary API 테스트 (JavaScript/Node.js)
 * 실제 API를 테스트하는 예제 코드
 */

// API 설정
const BASE_URL = 'https://your-app.onrender.com';  // Render URL로 변경
const API_KEY = 'test_api_key_1234567890';  // 실제 API Key로 변경
const USER_ID = '550e8400-e29b-41d4-a716-446655440000';  // 실제 User ID로 변경

const headers = {
  'X-API-Key': API_KEY,
  'Content-Type': 'application/json'
};

// API 호출 헬퍼 함수
async function apiCall(endpoint, method = 'GET', body = null) {
  const options = {
    method,
    headers
  };
  
  if (body) {
    options.body = JSON.stringify(body);
  }
  
  try {
    const response = await fetch(`${BASE_URL}${endpoint}`, options);
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${JSON.stringify(data)}`);
    }
    
    return data;
  } catch (error) {
    console.error(`API 호출 실패 (${endpoint}):`, error.message);
    throw error;
  }
}

// 1. Health Check
async function testHealthCheck() {
  console.log('=== Health Check ===');
  try {
    const result = await apiCall('/');
    console.log('✅ 서버 상태:', result.status);
    console.log('   버전:', result.version);
  } catch (error) {
    console.error('❌ 실패:', error.message);
  }
  console.log();
}

// 2. 캡처
async function testCapture() {
  console.log('=== Capture Test ===');
  
  // 최소 이미지 (1x1 픽셀 PNG)
  const imageData = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==';
  
  try {
    const result = await apiCall('/api/capture', 'POST', {
      user_id: USER_ID,
      image_data: imageData,
      source_url: 'https://example.com',
      page_title: 'JavaScript API Test',
      memo_content: 'Node.js로 테스트한 항목',
      platform: 'WEB_EXTENSION'
    });
    
    console.log('✅ 저장 성공!');
    console.log('   ID:', result.id);
    console.log('   제목:', result.page_title);
    console.log('   OCR 상태:', result.ocr_status);
    return result.id;
  } catch (error) {
    console.error('❌ 실패:', error.message);
    return null;
  }
}

// 3. 아이템 목록 조회
async function testGetItems() {
  console.log('=== Get Items ===');
  try {
    const items = await apiCall(`/api/items/${USER_ID}`);
    console.log(`✅ 조회 성공: ${items.length}개 항목`);
    items.slice(0, 3).forEach(item => {
      console.log(`   - ${item.page_title} (${item.ocr_status})`);
    });
  } catch (error) {
    console.error('❌ 실패:', error.message);
  }
  console.log();
}

// 4. 검색
async function testSearch(query) {
  console.log(`=== Search: '${query}' ===`);
  try {
    const results = await apiCall('/api/search', 'POST', {
      user_id: USER_ID,
      query: query
    });
    console.log(`✅ 검색 성공: ${results.length}개 결과`);
    results.forEach(item => {
      console.log(`   - ${item.page_title}`);
    });
  } catch (error) {
    console.error('❌ 실패:', error.message);
  }
  console.log();
}

// 5. 단일 아이템 조회
async function testGetItem(itemId) {
  console.log(`=== Get Item: ${itemId} ===`);
  try {
    const item = await apiCall(`/api/item/${itemId}`);
    console.log('✅ 조회 성공!');
    console.log('   제목:', item.page_title);
    console.log('   메모:', item.memo_content);
    console.log('   OCR:', item.ocr_status);
  } catch (error) {
    console.error('❌ 실패:', error.message);
  }
  console.log();
}

// 메인 테스트 함수
async function main() {
  console.log('='.repeat(60));
  console.log('Galmuri Diary API 테스트');
  console.log('='.repeat(60));
  console.log(`Base URL: ${BASE_URL}`);
  console.log(`User ID: ${USER_ID}`);
  console.log();
  
  // 1. Health Check
  await testHealthCheck();
  
  // 2. Capture
  const itemId = await testCapture();
  
  if (itemId) {
    // 3. Get Items
    await testGetItems();
    
    // 4. Get Item
    await testGetItem(itemId);
    
    // 5. Search
    await testSearch('JavaScript');
    await testSearch('테스트');
  }
  
  console.log('='.repeat(60));
  console.log('테스트 완료!');
  console.log('='.repeat(60));
}

// 실행
if (BASE_URL === 'https://your-app.onrender.com') {
  console.log('⚠️  BASE_URL을 실제 Render URL로 변경하세요!');
  console.log('   예: https://galmuri-diary-api.onrender.com');
  console.log();
}

// Node.js에서 실행
if (typeof require !== 'undefined') {
  // Node.js 환경
  const fetch = require('node-fetch');  // npm install node-fetch 필요
  main().catch(console.error);
} else {
  // 브라우저 환경
  main().catch(console.error);
}

