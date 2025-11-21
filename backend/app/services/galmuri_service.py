"""Galmuri Service - Business logic for managing galmuri items"""
import logging
from typing import Optional
from sqlalchemy import select, func, or_
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.galmuri_item import GalmuriItem, OCRStatus
from app.schemas.galmuri_item import GalmuriItemCreate, GalmuriItemUpdate
from app.services.ocr_service import OCRService

logger = logging.getLogger(__name__)


class GalmuriService:
    """
    Service for managing Galmuri items
    
    Responsibilities:
    - CRUD operations for Galmuri items
    - OCR processing coordination
    - Search functionality
    """
    
    def __init__(self, db: AsyncSession):
        """Initialize service with database session"""
        self.db = db
        self.ocr_service = OCRService()
    
    async def create_item(self, item_data: GalmuriItemCreate) -> GalmuriItem:
        """
        Create a new Galmuri item
        
        Process:
        1. Save item to database
        2. Trigger OCR processing asynchronously
        3. Update OCR results
        
        Args:
            item_data: Item creation data
            
        Returns:
            Created GalmuriItem
        """
        # Create new item
        db_item = GalmuriItem(
            user_id=item_data.user_id,
            image_data=item_data.image_data,
            source_url=item_data.source_url,
            page_title=item_data.page_title,
            memo_content=item_data.memo_content,
            platform=item_data.platform,
            ocr_status=OCRStatus.PENDING
        )
        
        self.db.add(db_item)
        await self.db.flush()  # Get ID without committing
        
        # Process OCR in background (non-blocking)
        await self._process_ocr(db_item)
        
        await self.db.commit()
        await self.db.refresh(db_item)
        
        logger.info(f"Created Galmuri item: {db_item.id}")
        return db_item
    
    async def _process_ocr(self, item: GalmuriItem) -> None:
        """
        Process OCR for a Galmuri item
        
        Args:
            item: GalmuriItem to process
        """
        try:
            # Extract text from image
            ocr_text, success = self.ocr_service.extract_text_from_base64(item.image_data)
            
            if success:
                item.ocr_text = ocr_text
                item.ocr_status = OCRStatus.DONE
                logger.info(f"OCR completed for item {item.id}")
            else:
                item.ocr_status = OCRStatus.FAILED
                logger.warning(f"OCR failed for item {item.id}")
                
        except Exception as e:
            item.ocr_status = OCRStatus.FAILED
            logger.error(f"OCR processing error for item {item.id}: {str(e)}")
    
    async def get_item(self, item_id: str, user_id: str) -> Optional[GalmuriItem]:
        """
        Get a single Galmuri item by ID
        
        Args:
            item_id: Item ID
            user_id: User ID for authorization
            
        Returns:
            GalmuriItem or None if not found
        """
        result = await self.db.execute(
            select(GalmuriItem).where(
                GalmuriItem.id == item_id,
                GalmuriItem.user_id == user_id
            )
        )
        return result.scalar_one_or_none()
    
    async def list_items(
        self,
        user_id: str,
        page: int = 1,
        page_size: int = 20,
        search_query: Optional[str] = None
    ) -> tuple[list[GalmuriItem], int]:
        """
        List Galmuri items with pagination and search
        
        Args:
            user_id: User ID
            page: Page number (1-indexed)
            page_size: Items per page
            search_query: Optional search query (searches in title, memo, and OCR text)
            
        Returns:
            Tuple of (items, total_count)
        """
        # Build base query
        query = select(GalmuriItem).where(GalmuriItem.user_id == user_id)
        
        # Add search filter if provided
        if search_query:
            search_filter = or_(
                GalmuriItem.page_title.ilike(f"%{search_query}%"),
                GalmuriItem.memo_content.ilike(f"%{search_query}%"),
                GalmuriItem.ocr_text.ilike(f"%{search_query}%")
            )
            query = query.where(search_filter)
        
        # Get total count
        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar_one()
        
        # Apply pagination and ordering
        query = query.order_by(GalmuriItem.created_at.desc())
        query = query.offset((page - 1) * page_size).limit(page_size)
        
        # Execute query
        result = await self.db.execute(query)
        items = list(result.scalars().all())
        
        return items, total
    
    async def update_item(
        self,
        item_id: str,
        user_id: str,
        update_data: GalmuriItemUpdate
    ) -> Optional[GalmuriItem]:
        """
        Update a Galmuri item
        
        Args:
            item_id: Item ID
            user_id: User ID for authorization
            update_data: Update data
            
        Returns:
            Updated GalmuriItem or None if not found
        """
        item = await self.get_item(item_id, user_id)
        if not item:
            return None
        
        # Update fields
        update_dict = update_data.model_dump(exclude_unset=True)
        for key, value in update_dict.items():
            setattr(item, key, value)
        
        await self.db.commit()
        await self.db.refresh(item)
        
        logger.info(f"Updated Galmuri item: {item_id}")
        return item
    
    async def delete_item(self, item_id: str, user_id: str) -> bool:
        """
        Delete a Galmuri item
        
        Args:
            item_id: Item ID
            user_id: User ID for authorization
            
        Returns:
            True if deleted, False if not found
        """
        item = await self.get_item(item_id, user_id)
        if not item:
            return False
        
        await self.db.delete(item)
        await self.db.commit()
        
        logger.info(f"Deleted Galmuri item: {item_id}")
        return True

