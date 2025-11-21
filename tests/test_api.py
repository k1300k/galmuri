"""
Integration tests for FastAPI endpoints
Tests the presentation layer
"""
import pytest
from fastapi.testclient import TestClient
from uuid import uuid4
import base64
from io import BytesIO
from PIL import Image

from backend.presentation.main import app, get_repository, get_ocr_service
from backend.infrastructure.local_repository import LocalGalmuriRepository
from backend.application.ocr_service import MockOCRService


# Test API Key
TEST_API_KEY = "test_api_key_1234567890"
TEST_USER_ID = str(uuid4())


@pytest.fixture
def test_repository():
    """Create test repository with in-memory database"""
    repo = LocalGalmuriRepository(db_path=":memory:")
    return repo


@pytest.fixture
def test_ocr_service():
    """Create mock OCR service"""
    return MockOCRService(mock_text="테스트 OCR 텍스트")


@pytest.fixture
def client(test_repository, test_ocr_service):
    """Create test client with dependency overrides"""
    app.dependency_overrides[get_repository] = lambda: test_repository
    app.dependency_overrides[get_ocr_service] = lambda: test_ocr_service
    
    with TestClient(app) as c:
        yield c
    
    app.dependency_overrides.clear()


def create_test_image() -> str:
    """Create a test image and return as base64"""
    img = Image.new('RGB', (100, 100), color='white')
    buffered = BytesIO()
    img.save(buffered, format="PNG")
    img_base64 = base64.b64encode(buffered.getvalue()).decode()
    return img_base64


class TestHealthCheck:
    """Test health check endpoint"""
    
    def test_root_endpoint(self, client):
        """Should return service information"""
        response = client.get("/")
        
        assert response.status_code == 200
        data = response.json()
        assert data["service"] == "Galmuri Diary API"
        assert data["status"] == "running"


class TestCaptureEndpoint:
    """Test capture endpoint"""
    
    def test_capture_without_api_key(self, client):
        """Should reject request without API key"""
        response = client.post("/api/capture", json={})
        
        assert response.status_code == 422  # Validation error
    
    def test_capture_with_invalid_api_key(self, client):
        """Should reject request with invalid API key"""
        response = client.post(
            "/api/capture",
            json={},
            headers={"X-API-Key": "short"}
        )
        
        assert response.status_code == 401
    
    def test_capture_success(self, client):
        """Should capture item successfully"""
        image_data = create_test_image()
        
        response = client.post(
            "/api/capture",
            json={
                "user_id": TEST_USER_ID,
                "image_data": image_data,
                "source_url": "https://example.com",
                "page_title": "Test Page",
                "memo_content": "Test memo",
                "platform": "WEB_EXTENSION"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["user_id"] == TEST_USER_ID
        assert data["page_title"] == "Test Page"
        assert data["memo_content"] == "Test memo"
        assert data["ocr_status"] == "PENDING"
        assert data["platform"] == "WEB_EXTENSION"


class TestGetItemsEndpoint:
    """Test get items endpoint"""
    
    def test_get_items_empty(self, client):
        """Should return empty list for new user"""
        response = client.get(
            f"/api/items/{TEST_USER_ID}",
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 0
    
    def test_get_items_after_capture(self, client):
        """Should return captured items"""
        # First, capture an item
        image_data = create_test_image()
        
        client.post(
            "/api/capture",
            json={
                "user_id": TEST_USER_ID,
                "image_data": image_data,
                "page_title": "Test Page",
                "platform": "WEB_EXTENSION"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        # Then, get items
        response = client.get(
            f"/api/items/{TEST_USER_ID}",
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 1
        assert data[0]["page_title"] == "Test Page"


class TestSearchEndpoint:
    """Test search endpoint"""
    
    def test_search_success(self, client):
        """Should search items successfully"""
        # First, capture items
        image_data = create_test_image()
        
        client.post(
            "/api/capture",
            json={
                "user_id": TEST_USER_ID,
                "image_data": image_data,
                "page_title": "배달의민족 주문",
                "platform": "WEB_EXTENSION"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        client.post(
            "/api/capture",
            json={
                "user_id": TEST_USER_ID,
                "image_data": image_data,
                "page_title": "쿠팡 장바구니",
                "platform": "WEB_EXTENSION"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        # Search
        response = client.post(
            "/api/search",
            json={
                "user_id": TEST_USER_ID,
                "query": "배달"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 1
        assert "배달" in data[0]["page_title"]


class TestGetItemEndpoint:
    """Test get single item endpoint"""
    
    def test_get_nonexistent_item(self, client):
        """Should return 404 for nonexistent item"""
        fake_id = str(uuid4())
        
        response = client.get(
            f"/api/item/{fake_id}",
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 404
    
    def test_get_existing_item(self, client):
        """Should return item by ID"""
        # First, capture an item
        image_data = create_test_image()
        
        capture_response = client.post(
            "/api/capture",
            json={
                "user_id": TEST_USER_ID,
                "image_data": image_data,
                "page_title": "Specific Item",
                "platform": "WEB_EXTENSION"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        item_id = capture_response.json()["id"]
        
        # Then, get the item
        response = client.get(
            f"/api/item/{item_id}",
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == item_id
        assert data["page_title"] == "Specific Item"


class TestDeleteItemEndpoint:
    """Test delete item endpoint"""
    
    def test_delete_item_success(self, client):
        """Should delete item successfully"""
        # First, capture an item
        image_data = create_test_image()
        
        capture_response = client.post(
            "/api/capture",
            json={
                "user_id": TEST_USER_ID,
                "image_data": image_data,
                "page_title": "To Delete",
                "platform": "WEB_EXTENSION"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        item_id = capture_response.json()["id"]
        
        # Delete the item
        response = client.delete(
            f"/api/item/{item_id}",
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        
        # Verify item is deleted
        get_response = client.get(
            f"/api/item/{item_id}",
            headers={"X-API-Key": TEST_API_KEY}
        )
        assert get_response.status_code == 404


class TestUnsyncedItemsEndpoint:
    """Test unsynced items endpoint"""
    
    def test_get_unsynced_items(self, client):
        """Should return unsynced items"""
        # Capture an item (will be unsynced by default)
        image_data = create_test_image()
        
        client.post(
            "/api/capture",
            json={
                "user_id": TEST_USER_ID,
                "image_data": image_data,
                "page_title": "Unsynced Item",
                "platform": "WEB_EXTENSION"
            },
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        # Get unsynced items
        response = client.get(
            f"/api/items/{TEST_USER_ID}/unsynced",
            headers={"X-API-Key": TEST_API_KEY}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) >= 1
        assert data[0]["is_synced"] is False


