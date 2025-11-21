"""
Domain Entities for Galmuri Diary
Represents core business objects
"""
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import UUID, uuid4


class OCRStatus(Enum):
    """OCR processing status"""
    PENDING = "PENDING"
    DONE = "DONE"
    FAILED = "FAILED"


class Platform(Enum):
    """Source platform"""
    MOBILE_APP = "MOBILE_APP"
    WEB_EXTENSION = "WEB_EXTENSION"


@dataclass
class GalmuriItem:
    """
    Core entity representing a captured item in Galmuri Diary
    Follows Domain-Driven Design principles
    """
    # Identifiers
    id: UUID = field(default_factory=uuid4)
    user_id: UUID = field(default_factory=uuid4)
    
    # Core Content
    image_data: str = ""  # Base64 encoded for local storage or file path for server
    source_url: Optional[str] = None
    page_title: str = ""
    memo_content: str = ""
    
    # Intelligence (OCR)
    ocr_text: str = ""
    ocr_status: OCRStatus = OCRStatus.PENDING
    
    # Meta & Sync
    platform: Platform = Platform.WEB_EXTENSION
    is_synced: bool = False
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)
    
    def mark_ocr_completed(self, extracted_text: str) -> None:
        """Mark OCR as completed with extracted text"""
        self.ocr_text = extracted_text
        self.ocr_status = OCRStatus.DONE
        self.updated_at = datetime.now()
    
    def mark_ocr_failed(self) -> None:
        """Mark OCR as failed"""
        self.ocr_status = OCRStatus.FAILED
        self.updated_at = datetime.now()
    
    def mark_synced(self) -> None:
        """Mark item as synced to server"""
        self.is_synced = True
        self.updated_at = datetime.now()
    
    def update_memo(self, new_memo: str) -> None:
        """Update memo content"""
        self.memo_content = new_memo
        self.updated_at = datetime.now()
    
    def is_searchable(self) -> bool:
        """Check if item is ready for search"""
        return self.ocr_status == OCRStatus.DONE or bool(self.memo_content)
    
    def get_search_keywords(self) -> str:
        """Get all searchable text combined"""
        keywords = []
        if self.page_title:
            keywords.append(self.page_title)
        if self.memo_content:
            keywords.append(self.memo_content)
        if self.ocr_text:
            keywords.append(self.ocr_text)
        return " ".join(keywords)

