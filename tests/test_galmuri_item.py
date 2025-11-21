"""
Tests for GalmuriItem domain entity
Following TDD principles
"""
import pytest
from datetime import datetime
from uuid import UUID
from backend.domain.entities import GalmuriItem, OCRStatus, Platform


class TestGalmuriItemCreation:
    """Test GalmuriItem creation and initialization"""
    
    def test_create_default_galmuri_item(self):
        """Should create item with default values"""
        item = GalmuriItem()
        
        assert isinstance(item.id, UUID)
        assert isinstance(item.user_id, UUID)
        assert item.image_data == ""
        assert item.source_url is None
        assert item.page_title == ""
        assert item.memo_content == ""
        assert item.ocr_text == ""
        assert item.ocr_status == OCRStatus.PENDING
        assert item.platform == Platform.WEB_EXTENSION
        assert item.is_synced is False
        assert isinstance(item.created_at, datetime)
        assert isinstance(item.updated_at, datetime)
    
    def test_create_galmuri_item_with_custom_values(self):
        """Should create item with provided values"""
        item = GalmuriItem(
            page_title="Test Page",
            source_url="https://example.com",
            memo_content="Test memo",
            platform=Platform.MOBILE_APP
        )
        
        assert item.page_title == "Test Page"
        assert item.source_url == "https://example.com"
        assert item.memo_content == "Test memo"
        assert item.platform == Platform.MOBILE_APP


class TestGalmuriItemOCROperations:
    """Test OCR-related operations"""
    
    def test_mark_ocr_completed(self):
        """Should mark OCR as completed with extracted text"""
        item = GalmuriItem()
        extracted_text = "배달의민족 주문 완료"
        initial_updated_at = item.updated_at
        
        item.mark_ocr_completed(extracted_text)
        
        assert item.ocr_text == extracted_text
        assert item.ocr_status == OCRStatus.DONE
        assert item.updated_at >= initial_updated_at
    
    def test_mark_ocr_failed(self):
        """Should mark OCR as failed"""
        item = GalmuriItem()
        initial_updated_at = item.updated_at
        
        item.mark_ocr_failed()
        
        assert item.ocr_status == OCRStatus.FAILED
        assert item.updated_at >= initial_updated_at


class TestGalmuriItemSyncOperations:
    """Test sync-related operations"""
    
    def test_mark_synced(self):
        """Should mark item as synced"""
        item = GalmuriItem()
        assert item.is_synced is False
        
        item.mark_synced()
        
        assert item.is_synced is True
    
    def test_update_memo(self):
        """Should update memo content"""
        item = GalmuriItem(memo_content="Initial memo")
        initial_updated_at = item.updated_at
        
        item.update_memo("Updated memo")
        
        assert item.memo_content == "Updated memo"
        assert item.updated_at >= initial_updated_at


class TestGalmuriItemSearchOperations:
    """Test search-related operations"""
    
    def test_is_searchable_with_ocr_done(self):
        """Should be searchable when OCR is done"""
        item = GalmuriItem()
        item.mark_ocr_completed("Some text")
        
        assert item.is_searchable() is True
    
    def test_is_searchable_with_memo_only(self):
        """Should be searchable when memo exists"""
        item = GalmuriItem(memo_content="Some memo")
        
        assert item.is_searchable() is True
    
    def test_is_not_searchable_when_empty(self):
        """Should not be searchable when no content"""
        item = GalmuriItem()
        
        # OCR is still pending and no memo
        assert item.is_searchable() is False
    
    def test_get_search_keywords(self):
        """Should return combined searchable text"""
        item = GalmuriItem(
            page_title="배민 주문",
            memo_content="점심 주문함",
        )
        item.mark_ocr_completed("배달의민족 주문완료")
        
        keywords = item.get_search_keywords()
        
        assert "배민 주문" in keywords
        assert "점심 주문함" in keywords
        assert "배달의민족 주문완료" in keywords
    
    def test_get_search_keywords_empty(self):
        """Should return empty string when no content"""
        item = GalmuriItem()
        
        keywords = item.get_search_keywords()
        
        assert keywords == ""

