"""
Tests for LocalGalmuriRepository
Following TDD principles
"""
import pytest
import os
import asyncio
from uuid import uuid4
from backend.domain.entities import GalmuriItem, Platform
from backend.infrastructure.local_repository import LocalGalmuriRepository


@pytest.fixture
def test_db_path(tmp_path):
    """Provide temporary database path"""
    return str(tmp_path / "test_galmuri.db")


@pytest.fixture
def repository(test_db_path):
    """Provide repository instance with test database"""
    return LocalGalmuriRepository(test_db_path)


@pytest.fixture
def sample_item():
    """Provide sample GalmuriItem"""
    return GalmuriItem(
        user_id=uuid4(),
        page_title="테스트 페이지",
        source_url="https://example.com",
        memo_content="테스트 메모",
        image_data="base64_encoded_image_data",
        platform=Platform.WEB_EXTENSION
    )


class TestLocalRepositorySave:
    """Test save operations"""
    
    @pytest.mark.asyncio
    async def test_save_new_item(self, repository, sample_item):
        """Should save new item successfully"""
        saved_item = await repository.save(sample_item)
        
        assert saved_item.id == sample_item.id
        assert saved_item.page_title == sample_item.page_title
    
    @pytest.mark.asyncio
    async def test_save_updates_existing_item(self, repository, sample_item):
        """Should update existing item"""
        # Save initial item
        await repository.save(sample_item)
        
        # Update and save again
        sample_item.update_memo("업데이트된 메모")
        updated_item = await repository.save(sample_item)
        
        # Retrieve and verify
        retrieved = await repository.find_by_id(sample_item.id)
        assert retrieved.memo_content == "업데이트된 메모"


class TestLocalRepositoryFind:
    """Test find operations"""
    
    @pytest.mark.asyncio
    async def test_find_by_id(self, repository, sample_item):
        """Should find item by ID"""
        await repository.save(sample_item)
        
        found_item = await repository.find_by_id(sample_item.id)
        
        assert found_item is not None
        assert found_item.id == sample_item.id
        assert found_item.page_title == sample_item.page_title
    
    @pytest.mark.asyncio
    async def test_find_by_id_not_found(self, repository):
        """Should return None when item not found"""
        found_item = await repository.find_by_id(uuid4())
        
        assert found_item is None
    
    @pytest.mark.asyncio
    async def test_find_by_user_id(self, repository):
        """Should find all items for a user"""
        user_id = uuid4()
        
        # Create multiple items for same user
        item1 = GalmuriItem(user_id=user_id, page_title="Item 1")
        item2 = GalmuriItem(user_id=user_id, page_title="Item 2")
        item3 = GalmuriItem(user_id=uuid4(), page_title="Other User Item")
        
        await repository.save(item1)
        await repository.save(item2)
        await repository.save(item3)
        
        items = await repository.find_by_user_id(user_id)
        
        assert len(items) == 2
        assert all(item.user_id == user_id for item in items)


class TestLocalRepositorySearch:
    """Test search operations"""
    
    @pytest.mark.asyncio
    async def test_search_by_page_title(self, repository):
        """Should search items by page title"""
        user_id = uuid4()
        
        item1 = GalmuriItem(user_id=user_id, page_title="배달의민족 주문")
        item2 = GalmuriItem(user_id=user_id, page_title="쿠팡 쇼핑")
        
        await repository.save(item1)
        await repository.save(item2)
        
        results = await repository.search(user_id, "배민")
        
        assert len(results) == 1
        assert results[0].page_title == "배달의민족 주문"
    
    @pytest.mark.asyncio
    async def test_search_by_memo_content(self, repository):
        """Should search items by memo content"""
        user_id = uuid4()
        
        item = GalmuriItem(
            user_id=user_id,
            page_title="주문 내역",
            memo_content="점심으로 피자 주문함"
        )
        
        await repository.save(item)
        
        results = await repository.search(user_id, "피자")
        
        assert len(results) == 1
        assert results[0].memo_content == "점심으로 피자 주문함"
    
    @pytest.mark.asyncio
    async def test_search_by_ocr_text(self, repository):
        """Should search items by OCR text"""
        user_id = uuid4()
        
        item = GalmuriItem(user_id=user_id, page_title="스크린샷")
        item.mark_ocr_completed("배달의민족 주문 완료")
        
        await repository.save(item)
        
        results = await repository.search(user_id, "주문 완료")
        
        assert len(results) == 1
        assert "주문 완료" in results[0].ocr_text
    
    @pytest.mark.asyncio
    async def test_search_no_results(self, repository):
        """Should return empty list when no matches"""
        user_id = uuid4()
        
        item = GalmuriItem(user_id=user_id, page_title="테스트")
        await repository.save(item)
        
        results = await repository.search(user_id, "존재하지않는검색어")
        
        assert len(results) == 0


class TestLocalRepositorySync:
    """Test sync operations"""
    
    @pytest.mark.asyncio
    async def test_find_unsynced_items(self, repository):
        """Should find only unsynced items"""
        user_id = uuid4()
        
        synced_item = GalmuriItem(user_id=user_id, page_title="Synced")
        synced_item.mark_synced()
        
        unsynced_item = GalmuriItem(user_id=user_id, page_title="Unsynced")
        
        await repository.save(synced_item)
        await repository.save(unsynced_item)
        
        unsynced_items = await repository.find_unsynced(user_id)
        
        assert len(unsynced_items) == 1
        assert unsynced_items[0].page_title == "Unsynced"
        assert unsynced_items[0].is_synced is False


class TestLocalRepositoryDelete:
    """Test delete operations"""
    
    @pytest.mark.asyncio
    async def test_delete_existing_item(self, repository, sample_item):
        """Should delete existing item"""
        await repository.save(sample_item)
        
        deleted = await repository.delete(sample_item.id)
        
        assert deleted is True
        
        # Verify item is deleted
        found = await repository.find_by_id(sample_item.id)
        assert found is None
    
    @pytest.mark.asyncio
    async def test_delete_nonexistent_item(self, repository):
        """Should return False when deleting nonexistent item"""
        deleted = await repository.delete(uuid4())
        
        assert deleted is False

