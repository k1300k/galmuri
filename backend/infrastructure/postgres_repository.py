"""
PostgreSQL Repository Implementation
For production deployment on Render, Railway, etc.
"""
import os
from typing import List, Optional
from uuid import UUID
from datetime import datetime
from sqlalchemy import create_engine, Column, String, Text, DateTime, Boolean, Index
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.dialects.postgresql import UUID as PGUUID

from domain.entities import GalmuriItem, OCRStatus, Platform
from domain.repositories import IGalmuriRepository

Base = declarative_base()


class GalmuriItemModel(Base):
    """SQLAlchemy model for PostgreSQL"""
    __tablename__ = "galmuri_items"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), nullable=False, index=True)
    image_data = Column(Text, nullable=False)
    source_url = Column(String(2048), nullable=True)
    page_title = Column(String(512), nullable=False)
    memo_content = Column(Text, nullable=True)
    ocr_text = Column(Text, nullable=True)
    ocr_status = Column(String(20), nullable=False, default="PENDING")
    platform = Column(String(20), nullable=False, default="WEB_EXTENSION")
    is_synced = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, nullable=False)
    updated_at = Column(DateTime, nullable=False)
    
    # Create indexes for better search performance
    __table_args__ = (
        Index('idx_user_id', 'user_id'),
        Index('idx_is_synced', 'is_synced'),
        Index('idx_created_at', 'created_at'),
    )


class PostgresGalmuriRepository(IGalmuriRepository):
    """
    PostgreSQL implementation of IGalmuriRepository
    For production deployment
    """
    
    def __init__(self, database_url: str):
        """
        Initialize PostgreSQL repository
        
        Args:
            database_url: PostgreSQL connection string
                Format: postgresql://user:password@host:port/database
        """
        self.engine = create_engine(
            database_url,
            pool_pre_ping=True,  # Verify connections before using
            pool_recycle=3600,   # Recycle connections after 1 hour
        )
        Base.metadata.create_all(self.engine)
        self.Session = sessionmaker(bind=self.engine)
    
    def _to_entity(self, model: GalmuriItemModel) -> GalmuriItem:
        """Convert SQLAlchemy model to domain entity"""
        return GalmuriItem(
            id=UUID(model.id),
            user_id=UUID(model.user_id),
            image_data=model.image_data,
            source_url=model.source_url,
            page_title=model.page_title,
            memo_content=model.memo_content or '',
            ocr_text=model.ocr_text or '',
            ocr_status=OCRStatus(model.ocr_status),
            platform=Platform(model.platform),
            is_synced=model.is_synced,
            created_at=model.created_at,
            updated_at=model.updated_at,
        )
    
    def _to_model(self, entity: GalmuriItem) -> GalmuriItemModel:
        """Convert domain entity to SQLAlchemy model"""
        return GalmuriItemModel(
            id=str(entity.id),
            user_id=str(entity.user_id),
            image_data=entity.image_data,
            source_url=entity.source_url,
            page_title=entity.page_title,
            memo_content=entity.memo_content,
            ocr_text=entity.ocr_text,
            ocr_status=entity.ocr_status.value,
            platform=entity.platform.value,
            is_synced=entity.is_synced,
            created_at=entity.created_at,
            updated_at=entity.updated_at,
        )
    
    async def save(self, item: GalmuriItem) -> GalmuriItem:
        """Save or update an item"""
        session: Session = self.Session()
        try:
            model = self._to_model(item)
            session.merge(model)  # Insert or update
            session.commit()
            return item
        except Exception as e:
            session.rollback()
            raise e
        finally:
            session.close()
    
    async def find_by_id(self, item_id: UUID) -> Optional[GalmuriItem]:
        """Find item by ID"""
        session: Session = self.Session()
        try:
            model = session.query(GalmuriItemModel).filter(
                GalmuriItemModel.id == str(item_id)
            ).first()
            
            if model:
                return self._to_entity(model)
            return None
        finally:
            session.close()
    
    async def find_by_user_id(self, user_id: UUID) -> List[GalmuriItem]:
        """Find all items for a user"""
        session: Session = self.Session()
        try:
            models = session.query(GalmuriItemModel).filter(
                GalmuriItemModel.user_id == str(user_id)
            ).order_by(GalmuriItemModel.created_at.desc()).all()
            
            return [self._to_entity(model) for model in models]
        finally:
            session.close()
    
    async def search(self, user_id: UUID, query: str) -> List[GalmuriItem]:
        """Search items by query"""
        session: Session = self.Session()
        try:
            search_pattern = f"%{query}%"
            models = session.query(GalmuriItemModel).filter(
                GalmuriItemModel.user_id == str(user_id),
                (
                    GalmuriItemModel.page_title.ilike(search_pattern) |
                    GalmuriItemModel.memo_content.ilike(search_pattern) |
                    GalmuriItemModel.ocr_text.ilike(search_pattern)
                )
            ).order_by(GalmuriItemModel.created_at.desc()).all()
            
            return [self._to_entity(model) for model in models]
        finally:
            session.close()
    
    async def find_unsynced(self, user_id: UUID) -> List[GalmuriItem]:
        """Find all unsynced items for a user"""
        session: Session = self.Session()
        try:
            models = session.query(GalmuriItemModel).filter(
                GalmuriItemModel.user_id == str(user_id),
                GalmuriItemModel.is_synced == False
            ).order_by(GalmuriItemModel.created_at.asc()).all()
            
            return [self._to_entity(model) for model in models]
        finally:
            session.close()
    
    async def delete(self, item_id: UUID) -> bool:
        """Delete an item"""
        session: Session = self.Session()
        try:
            result = session.query(GalmuriItemModel).filter(
                GalmuriItemModel.id == str(item_id)
            ).delete()
            session.commit()
            return result > 0
        except Exception as e:
            session.rollback()
            raise e
        finally:
            session.close()

