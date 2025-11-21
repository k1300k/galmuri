"""
FastAPI Main Application
Clean Architecture - Presentation Layer
"""
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel, Field
from datetime import datetime

import sys
from pathlib import Path

# Add backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

from domain.entities import GalmuriItem, OCRStatus, Platform
from domain.repositories import IGalmuriRepository
from infrastructure.local_repository import LocalGalmuriRepository
from application.ocr_service import IOCRService, TesseractOCRService
import asyncio

# Initialize FastAPI app
app = FastAPI(
    title="Galmuri Diary API",
    description="Hybrid Capture & Archiving System with OCR",
    version="1.0.0"
)

# CORS middleware for web extension
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency Injection
def get_repository() -> IGalmuriRepository:
    """Get repository instance"""
    import os
    database_url = os.getenv("DATABASE_URL")
    
    if database_url and database_url.startswith("postgresql"):
        # Production: PostgreSQL (Render, Railway, etc.)
        from infrastructure.postgres_repository import PostgresGalmuriRepository
        return PostgresGalmuriRepository(database_url)
    else:
        # Development: SQLite
        return LocalGalmuriRepository(db_path="galmuri.db")

def get_ocr_service() -> IOCRService:
    """Get OCR service instance"""
    try:
        return TesseractOCRService()
    except RuntimeError:
        # Tesseract not installed - use mock for development
        from application.ocr_service import MockOCRService
        return MockOCRService()

# Authentication
def verify_api_key(x_api_key: str = Header(...)) -> str:
    """Simple API key verification"""
    # MVP: Simple validation (in production, use proper auth)
    if not x_api_key or len(x_api_key) < 10:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return x_api_key

# Pydantic Models for API
class CaptureRequest(BaseModel):
    """Request model for capturing an item"""
    user_id: str = Field(..., description="User UUID")
    image_data: str = Field(..., description="Base64 encoded image")
    source_url: Optional[str] = Field(None, description="Original URL")
    page_title: str = Field(..., description="Page title")
    memo_content: str = Field(default="", description="User memo")
    platform: str = Field(default="WEB_EXTENSION", description="Platform")

class ItemResponse(BaseModel):
    """Response model for item"""
    id: str
    user_id: str
    source_url: Optional[str]
    page_title: str
    memo_content: str
    ocr_text: str
    ocr_status: str
    platform: str
    is_synced: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class SearchRequest(BaseModel):
    """Request model for search"""
    user_id: str
    query: str

# API Endpoints
@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "service": "Galmuri Diary API",
        "version": "1.0.0",
        "status": "running"
    }

@app.post("/api/capture", response_model=ItemResponse)
async def capture_item(
    request: CaptureRequest,
    repository: IGalmuriRepository = Depends(get_repository),
    ocr_service: IOCRService = Depends(get_ocr_service),
    api_key: str = Depends(verify_api_key)
):
    """
    Capture and save an item
    Processes OCR in background
    """
    try:
        # Create new item
        item = GalmuriItem(
            user_id=UUID(request.user_id),
            image_data=request.image_data,
            source_url=request.source_url,
            page_title=request.page_title,
            memo_content=request.memo_content,
            platform=Platform(request.platform)
        )
        
        # Save immediately (Local First)
        saved_item = await repository.save(item)
        
        # Process OCR in background (non-blocking)
        asyncio.create_task(process_ocr_background(
            item_id=saved_item.id,
            image_data=request.image_data,
            repository=repository,
            ocr_service=ocr_service
        ))
        
        return ItemResponse(
            id=str(saved_item.id),
            user_id=str(saved_item.user_id),
            source_url=saved_item.source_url,
            page_title=saved_item.page_title,
            memo_content=saved_item.memo_content,
            ocr_text=saved_item.ocr_text,
            ocr_status=saved_item.ocr_status.value,
            platform=saved_item.platform.value,
            is_synced=saved_item.is_synced,
            created_at=saved_item.created_at,
            updated_at=saved_item.updated_at
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to capture item: {str(e)}")

async def process_ocr_background(
    item_id: UUID,
    image_data: str,
    repository: IGalmuriRepository,
    ocr_service: IOCRService
):
    """Background task for OCR processing"""
    try:
        # Extract text from image
        extracted_text = await ocr_service.extract_text(image_data)
        
        # Update item with OCR result
        item = await repository.find_by_id(item_id)
        if item:
            item.mark_ocr_completed(extracted_text)
            await repository.save(item)
            
    except Exception as e:
        # Mark OCR as failed
        item = await repository.find_by_id(item_id)
        if item:
            item.mark_ocr_failed()
            await repository.save(item)
        print(f"OCR processing failed for item {item_id}: {str(e)}")

@app.get("/api/items/{user_id}", response_model=List[ItemResponse])
async def get_user_items(
    user_id: str,
    repository: IGalmuriRepository = Depends(get_repository),
    api_key: str = Depends(verify_api_key)
):
    """Get all items for a user"""
    try:
        items = await repository.find_by_user_id(UUID(user_id))
        
        return [
            ItemResponse(
                id=str(item.id),
                user_id=str(item.user_id),
                source_url=item.source_url,
                page_title=item.page_title,
                memo_content=item.memo_content,
                ocr_text=item.ocr_text,
                ocr_status=item.ocr_status.value,
                platform=item.platform.value,
                is_synced=item.is_synced,
                created_at=item.created_at,
                updated_at=item.updated_at
            )
            for item in items
        ]
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve items: {str(e)}")

@app.post("/api/search", response_model=List[ItemResponse])
async def search_items(
    request: SearchRequest,
    repository: IGalmuriRepository = Depends(get_repository),
    api_key: str = Depends(verify_api_key)
):
    """
    Search items by query
    Searches in title, memo, and OCR text
    """
    try:
        items = await repository.search(UUID(request.user_id), request.query)
        
        return [
            ItemResponse(
                id=str(item.id),
                user_id=str(item.user_id),
                source_url=item.source_url,
                page_title=item.page_title,
                memo_content=item.memo_content,
                ocr_text=item.ocr_text,
                ocr_status=item.ocr_status.value,
                platform=item.platform.value,
                is_synced=item.is_synced,
                created_at=item.created_at,
                updated_at=item.updated_at
            )
            for item in items
        ]
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@app.get("/api/items/{user_id}/unsynced", response_model=List[ItemResponse])
async def get_unsynced_items(
    user_id: str,
    repository: IGalmuriRepository = Depends(get_repository),
    api_key: str = Depends(verify_api_key)
):
    """Get all unsynced items for a user"""
    try:
        items = await repository.find_unsynced(UUID(user_id))
        
        return [
            ItemResponse(
                id=str(item.id),
                user_id=str(item.user_id),
                source_url=item.source_url,
                page_title=item.page_title,
                memo_content=item.memo_content,
                ocr_text=item.ocr_text,
                ocr_status=item.ocr_status.value,
                platform=item.platform.value,
                is_synced=item.is_synced,
                created_at=item.created_at,
                updated_at=item.updated_at
            )
            for item in items
        ]
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve unsynced items: {str(e)}")

@app.get("/api/item/{item_id}", response_model=ItemResponse)
async def get_item(
    item_id: str,
    repository: IGalmuriRepository = Depends(get_repository),
    api_key: str = Depends(verify_api_key)
):
    """Get a specific item by ID"""
    try:
        item = await repository.find_by_id(UUID(item_id))
        
        if not item:
            raise HTTPException(status_code=404, detail="Item not found")
        
        return ItemResponse(
            id=str(item.id),
            user_id=str(item.user_id),
            source_url=item.source_url,
            page_title=item.page_title,
            memo_content=item.memo_content,
            ocr_text=item.ocr_text,
            ocr_status=item.ocr_status.value,
            platform=item.platform.value,
            is_synced=item.is_synced,
            created_at=item.created_at,
            updated_at=item.updated_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve item: {str(e)}")

@app.delete("/api/item/{item_id}")
async def delete_item(
    item_id: str,
    repository: IGalmuriRepository = Depends(get_repository),
    api_key: str = Depends(verify_api_key)
):
    """Delete an item"""
    try:
        success = await repository.delete(UUID(item_id))
        
        if not success:
            raise HTTPException(status_code=404, detail="Item not found")
        
        return {"success": True, "message": "Item deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete item: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

