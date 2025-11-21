"""
Tests for Galmuri Service (Application Layer)
Following TDD principles - Test First
"""
import pytest
from uuid import UUID, uuid4
from backend.domain.entities import GalmuriItem, OCRStatus, Platform
from backend.domain.repositories import IGalmuriRepository
from backend.application.ocr_service import MockOCRService
from typing import List, Optional


class MockGalmuriRepository(IGalmuriRepository):
    """Mock repository for testing"""
    
    def __init__(self):
        self.items = {}
    
    async def save(self, item: GalmuriItem) -> GalmuriItem:
        self.items[item.id] = item
        return item
    
    async def find_by_id(self, item_id: UUID) -> Optional[GalmuriItem]:
        return self.items.get(item_id)
    
    async def find_by_user_id(self, user_id: UUID) -> List[GalmuriItem]:
        return [item for item in self.items.values() if item.user_id == user_id]
    
    async def search(self, user_id: UUID, query: str) -> List[GalmuriItem]:
        results = []
        for item in self.items.values():
            if item.user_id == user_id:
                search_text = item.get_search_keywords().lower()
                if query.lower() in search_text:
                    results.append(item)
        return results
    
    async def find_unsynced(self, user_id: UUID) -> List[GalmuriItem]:
        return [
            item for item in self.items.values()
            if item.user_id == user_id and not item.is_synced
        ]
    
    async def delete(self, item_id: UUID) -> bool:
        if item_id in self.items:
            del self.items[item_id]
            return True
        return False


class TestGalmuriService:
    """Test Galmuri Service business logic"""
    
    @pytest.mark.asyncio
    async def test_create_and_save_item(self):
        """Should create and save a new item"""
        repository = MockGalmuriRepository()
        user_id = uuid4()
        
        # Create item
        item = GalmuriItem(
            user_id=user_id,
            image_data="base64_image_data",
            source_url="https://example.com",
            page_title="Test Page",
            memo_content="Test memo"
        )
        
        # Save item
        saved_item = await repository.save(item)
        
        # Verify
        assert saved_item.id == item.id
        assert saved_item.user_id == user_id
        assert saved_item.page_title == "Test Page"
        assert saved_item.ocr_status == OCRStatus.PENDING
    
    @pytest.mark.asyncio
    async def test_process_ocr_and_update(self):
        """Should process OCR and update item"""
        repository = MockGalmuriRepository()
        ocr_service = MockOCRService(mock_text="추출된 텍스트")
        
        # Create and save item
        item = GalmuriItem(
            user_id=uuid4(),
            image_data="base64_image_data",
            page_title="Test Page"
        )
        await repository.save(item)
        
        # Process OCR
        extracted_text = await ocr_service.extract_text(item.image_data)
        item.mark_ocr_completed(extracted_text)
        
        # Update item
        updated_item = await repository.save(item)
        
        # Verify
        assert updated_item.ocr_text == "추출된 텍스트"
        assert updated_item.ocr_status == OCRStatus.DONE
    
    @pytest.mark.asyncio
    async def test_search_in_title(self):
        """Should find items by title"""
        repository = MockGalmuriRepository()
        user_id = uuid4()
        
        # Create items
        item1 = GalmuriItem(
            user_id=user_id,
            page_title="배달의민족 주문",
            image_data="image1"
        )
        item2 = GalmuriItem(
            user_id=user_id,
            page_title="쿠팡 장바구니",
            image_data="image2"
        )
        
        await repository.save(item1)
        await repository.save(item2)
        
        # Search
        results = await repository.search(user_id, "배달")
        
        # Verify
        assert len(results) == 1
        assert results[0].page_title == "배달의민족 주문"
    
    @pytest.mark.asyncio
    async def test_search_in_ocr_text(self):
        """Should find items by OCR text"""
        repository = MockGalmuriRepository()
        user_id = uuid4()
        
        # Create item with OCR text
        item = GalmuriItem(
            user_id=user_id,
            page_title="스크린샷",
            image_data="image1"
        )
        item.mark_ocr_completed("배달의민족 앱에서 주문하기")
        
        await repository.save(item)
        
        # Search for text that's only in OCR
        results = await repository.search(user_id, "배달")
        
        # Verify
        assert len(results) == 1
        assert "배달의민족" in results[0].ocr_text
    
    @pytest.mark.asyncio
    async def test_search_in_memo(self):
        """Should find items by memo content"""
        repository = MockGalmuriRepository()
        user_id = uuid4()
        
        # Create item with memo
        item = GalmuriItem(
            user_id=user_id,
            page_title="메모 테스트",
            memo_content="이 페이지는 배달음식 관련 정보입니다",
            image_data="image1"
        )
        
        await repository.save(item)
        
        # Search
        results = await repository.search(user_id, "배달음식")
        
        # Verify
        assert len(results) == 1
    
    @pytest.mark.asyncio
    async def test_find_unsynced_items(self):
        """Should find only unsynced items"""
        repository = MockGalmuriRepository()
        user_id = uuid4()
        
        # Create synced item
        item1 = GalmuriItem(user_id=user_id, page_title="Synced", image_data="img1")
        item1.mark_synced()
        
        # Create unsynced item
        item2 = GalmuriItem(user_id=user_id, page_title="Unsynced", image_data="img2")
        
        await repository.save(item1)
        await repository.save(item2)
        
        # Find unsynced
        unsynced = await repository.find_unsynced(user_id)
        
        # Verify
        assert len(unsynced) == 1
        assert unsynced[0].page_title == "Unsynced"
        assert not unsynced[0].is_synced
    
    @pytest.mark.asyncio
    async def test_delete_item(self):
        """Should delete an item"""
        repository = MockGalmuriRepository()
        
        # Create and save item
        item = GalmuriItem(
            user_id=uuid4(),
            page_title="To Delete",
            image_data="image"
        )
        await repository.save(item)
        
        # Verify item exists
        found = await repository.find_by_id(item.id)
        assert found is not None
        
        # Delete item
        success = await repository.delete(item.id)
        assert success is True
        
        # Verify item is deleted
        found = await repository.find_by_id(item.id)
        assert found is None
    
    @pytest.mark.asyncio
    async def test_update_memo(self):
        """Should update memo content"""
        repository = MockGalmuriRepository()
        
        # Create item
        item = GalmuriItem(
            user_id=uuid4(),
            page_title="Test",
            memo_content="Original memo",
            image_data="image"
        )
        await repository.save(item)
        
        # Update memo
        item.update_memo("Updated memo")
        await repository.save(item)
        
        # Verify
        updated = await repository.find_by_id(item.id)
        assert updated.memo_content == "Updated memo"
    
    @pytest.mark.asyncio
    async def test_is_searchable(self):
        """Should determine if item is searchable"""
        # Item with OCR completed
        item1 = GalmuriItem(
            user_id=uuid4(),
            page_title="Test",
            image_data="image"
        )
        item1.mark_ocr_completed("OCR text")
        assert item1.is_searchable() is True
        
        # Item with memo but no OCR
        item2 = GalmuriItem(
            user_id=uuid4(),
            page_title="Test",
            memo_content="Some memo",
            image_data="image"
        )
        assert item2.is_searchable() is True
        
        # Item with neither
        item3 = GalmuriItem(
            user_id=uuid4(),
            page_title="Test",
            image_data="image"
        )
        assert item3.is_searchable() is False
    
    @pytest.mark.asyncio
    async def test_get_search_keywords(self):
        """Should combine all searchable text"""
        item = GalmuriItem(
            user_id=uuid4(),
            page_title="Title Text",
            memo_content="Memo Text",
            image_data="image"
        )
        item.mark_ocr_completed("OCR Text")
        
        keywords = item.get_search_keywords()
        
        assert "Title Text" in keywords
        assert "Memo Text" in keywords
        assert "OCR Text" in keywords


