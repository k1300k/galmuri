"""
Repository interfaces (Port pattern in Clean Architecture)
Defines contracts for data persistence without implementation details
"""
from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID
from .entities import GalmuriItem


class IGalmuriRepository(ABC):
    """
    Repository interface for GalmuriItem
    Follows Interface Segregation Principle
    """
    
    @abstractmethod
    async def save(self, item: GalmuriItem) -> GalmuriItem:
        """Save or update an item"""
        pass
    
    @abstractmethod
    async def find_by_id(self, item_id: UUID) -> Optional[GalmuriItem]:
        """Find item by ID"""
        pass
    
    @abstractmethod
    async def find_by_user_id(self, user_id: UUID) -> List[GalmuriItem]:
        """Find all items for a user"""
        pass
    
    @abstractmethod
    async def search(self, user_id: UUID, query: str) -> List[GalmuriItem]:
        """Search items by query (searches in title, memo, and OCR text)"""
        pass
    
    @abstractmethod
    async def find_unsynced(self, user_id: UUID) -> List[GalmuriItem]:
        """Find all unsynced items for a user"""
        pass
    
    @abstractmethod
    async def delete(self, item_id: UUID) -> bool:
        """Delete an item"""
        pass

