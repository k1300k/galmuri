"""Galmuri Item Data Model - Local First Architecture with OCR Support"""
import uuid
from datetime import datetime
from enum import Enum
from sqlalchemy import Column, String, Text, DateTime, Boolean, Enum as SQLEnum
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import UUID

Base = declarative_base()


class Platform(str, Enum):
    """출처 플랫폼 구분"""
    MOBILE_APP = "MOBILE_APP"
    WEB_EXTENSION = "WEB_EXTENSION"


class OCRStatus(str, Enum):
    """OCR 처리 상태"""
    PENDING = "PENDING"
    DONE = "DONE"
    FAILED = "FAILED"


class GalmuriItem(Base):
    """
    갈무리 아이템 데이터 모델
    
    Local First 아키텍처를 위해 설계됨:
    - 로컬 DB에 우선 저장
    - 백그라운드에서 서버 동기화
    - OCR을 통한 이미지 텍스트 추출
    """
    __tablename__ = "galmuri_items"

    # Primary Keys
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), nullable=False, index=True)
    
    # Core Content
    image_data = Column(Text, nullable=False, comment="Base64 encoded image for local storage")
    source_url = Column(String(2048), nullable=True, comment="Original URL of captured page")
    page_title = Column(String(512), nullable=True, comment="Title of the web page")
    memo_content = Column(Text, nullable=True, comment="User's memo")
    
    # Intelligence (OCR)
    ocr_text = Column(Text, nullable=True, comment="Extracted text from image via OCR")
    ocr_status = Column(
        SQLEnum(OCRStatus, native_enum=False),
        nullable=False,
        default=OCRStatus.PENDING,
        comment="OCR processing status"
    )
    
    # Meta & Sync
    platform = Column(
        SQLEnum(Platform, native_enum=False),
        nullable=False,
        default=Platform.WEB_EXTENSION,
        comment="Source platform"
    )
    is_synced = Column(
        Boolean,
        nullable=False,
        default=False,
        comment="Whether synced to server"
    )
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<GalmuriItem(id={self.id}, title={self.page_title}, ocr_status={self.ocr_status})>"

