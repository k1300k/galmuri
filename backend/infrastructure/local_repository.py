"""
Local storage implementation of GalmuriRepository
Uses SQLite for MVP - suitable for Local First strategy
"""
import sqlite3
import json
from typing import List, Optional
from uuid import UUID
from datetime import datetime
from domain.entities import GalmuriItem, OCRStatus, Platform
from domain.repositories import IGalmuriRepository


class LocalGalmuriRepository(IGalmuriRepository):
    """
    SQLite implementation of IGalmuriRepository
    Follows Dependency Inversion Principle
    """
    
    def __init__(self, db_path: str = "galmuri.db"):
        self.db_path = db_path
        self._initialize_database()
    
    def _initialize_database(self) -> None:
        """Initialize database schema"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS galmuri_items (
                id TEXT PRIMARY KEY,
                user_id TEXT NOT NULL,
                image_data TEXT NOT NULL,
                source_url TEXT,
                page_title TEXT NOT NULL,
                memo_content TEXT NOT NULL,
                ocr_text TEXT NOT NULL,
                ocr_status TEXT NOT NULL,
                platform TEXT NOT NULL,
                is_synced INTEGER NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        """)
        
        # Create index for search optimization
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_user_id ON galmuri_items(user_id)
        """)
        
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_is_synced ON galmuri_items(is_synced)
        """)
        
        conn.commit()
        conn.close()
    
    def _to_dict(self, item: GalmuriItem) -> dict:
        """Convert GalmuriItem to dictionary for storage"""
        return {
            'id': str(item.id),
            'user_id': str(item.user_id),
            'image_data': item.image_data,
            'source_url': item.source_url,
            'page_title': item.page_title,
            'memo_content': item.memo_content,
            'ocr_text': item.ocr_text,
            'ocr_status': item.ocr_status.value,
            'platform': item.platform.value,
            'is_synced': 1 if item.is_synced else 0,
            'created_at': item.created_at.isoformat(),
            'updated_at': item.updated_at.isoformat()
        }
    
    def _from_row(self, row: tuple) -> GalmuriItem:
        """Convert database row to GalmuriItem"""
        return GalmuriItem(
            id=UUID(row[0]),
            user_id=UUID(row[1]),
            image_data=row[2],
            source_url=row[3],
            page_title=row[4],
            memo_content=row[5],
            ocr_text=row[6],
            ocr_status=OCRStatus(row[7]),
            platform=Platform(row[8]),
            is_synced=bool(row[9]),
            created_at=datetime.fromisoformat(row[10]),
            updated_at=datetime.fromisoformat(row[11])
        )
    
    async def save(self, item: GalmuriItem) -> GalmuriItem:
        """Save or update an item"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        data = self._to_dict(item)
        
        cursor.execute("""
            INSERT OR REPLACE INTO galmuri_items
            (id, user_id, image_data, source_url, page_title, memo_content,
             ocr_text, ocr_status, platform, is_synced, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            data['id'], data['user_id'], data['image_data'], data['source_url'],
            data['page_title'], data['memo_content'], data['ocr_text'],
            data['ocr_status'], data['platform'], data['is_synced'],
            data['created_at'], data['updated_at']
        ))
        
        conn.commit()
        conn.close()
        
        return item
    
    async def find_by_id(self, item_id: UUID) -> Optional[GalmuriItem]:
        """Find item by ID"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT * FROM galmuri_items WHERE id = ?
        """, (str(item_id),))
        
        row = cursor.fetchone()
        conn.close()
        
        if row:
            return self._from_row(row)
        return None
    
    async def find_by_user_id(self, user_id: UUID) -> List[GalmuriItem]:
        """Find all items for a user"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT * FROM galmuri_items 
            WHERE user_id = ?
            ORDER BY created_at DESC
        """, (str(user_id),))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [self._from_row(row) for row in rows]
    
    async def search(self, user_id: UUID, query: str) -> List[GalmuriItem]:
        """Search items by query"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        search_pattern = f"%{query}%"
        
        cursor.execute("""
            SELECT * FROM galmuri_items 
            WHERE user_id = ?
            AND (
                page_title LIKE ? OR
                memo_content LIKE ? OR
                ocr_text LIKE ?
            )
            ORDER BY created_at DESC
        """, (str(user_id), search_pattern, search_pattern, search_pattern))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [self._from_row(row) for row in rows]
    
    async def find_unsynced(self, user_id: UUID) -> List[GalmuriItem]:
        """Find all unsynced items for a user"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT * FROM galmuri_items 
            WHERE user_id = ? AND is_synced = 0
            ORDER BY created_at ASC
        """, (str(user_id),))
        
        rows = cursor.fetchall()
        conn.close()
        
        return [self._from_row(row) for row in rows]
    
    async def delete(self, item_id: UUID) -> bool:
        """Delete an item"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            DELETE FROM galmuri_items WHERE id = ?
        """, (str(item_id),))
        
        affected_rows = cursor.rowcount
        conn.commit()
        conn.close()
        
        return affected_rows > 0

