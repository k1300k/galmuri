"""Pydantic schemas for Galmuri Item validation"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict
from app.models.galmuri_item import Platform, OCRStatus


class GalmuriItemBase(BaseModel):
    """Base schema for Galmuri Item"""
    source_url: Optional[str] = Field(None, max_length=2048, description="Original URL of captured page")
    page_title: Optional[str] = Field(None, max_length=512, description="Title of the web page")
    memo_content: Optional[str] = Field(None, description="User's memo")
    platform: Platform = Field(default=Platform.WEB_EXTENSION, description="Source platform")


class GalmuriItemCreate(GalmuriItemBase):
    """Schema for creating a new Galmuri Item"""
    image_data: str = Field(..., description="Base64 encoded image data")
    user_id: str = Field(..., description="User ID")


class GalmuriItemUpdate(BaseModel):
    """Schema for updating an existing Galmuri Item"""
    memo_content: Optional[str] = Field(None, description="Updated memo content")
    ocr_text: Optional[str] = Field(None, description="Extracted OCR text")
    ocr_status: Optional[OCRStatus] = Field(None, description="OCR processing status")
    is_synced: Optional[bool] = Field(None, description="Sync status")


class GalmuriItemResponse(GalmuriItemBase):
    """Schema for Galmuri Item response"""
    id: str
    user_id: str
    image_data: str
    ocr_text: Optional[str] = None
    ocr_status: OCRStatus
    is_synced: bool
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class GalmuriItemList(BaseModel):
    """Schema for list of Galmuri Items"""
    items: list[GalmuriItemResponse]
    total: int
    page: int
    page_size: int

