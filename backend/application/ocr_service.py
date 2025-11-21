"""
OCR Service for extracting text from images
Follows Single Responsibility Principle
"""
from abc import ABC, abstractmethod
from typing import Optional
import base64
from io import BytesIO


class IOCRService(ABC):
    """Interface for OCR service"""
    
    @abstractmethod
    async def extract_text(self, image_data: str) -> str:
        """
        Extract text from image data
        
        Args:
            image_data: Base64 encoded image or file path
            
        Returns:
            Extracted text string
        """
        pass


class TesseractOCRService(IOCRService):
    """
    OCR service implementation using Tesseract
    """
    
    def __init__(self, language: str = 'kor+eng'):
        """
        Initialize Tesseract OCR service
        
        Args:
            language: Language code for OCR (default: 'kor+eng' for Korean and English)
        """
        self.language = language
        self._validate_tesseract()
    
    def _validate_tesseract(self) -> None:
        """Validate that Tesseract is installed"""
        try:
            import pytesseract
            # Test if tesseract is available
            pytesseract.get_tesseract_version()
        except Exception as e:
            raise RuntimeError(
                "Tesseract is not installed or not found. "
                "Please install Tesseract OCR: https://github.com/tesseract-ocr/tesseract"
            ) from e
    
    async def extract_text(self, image_data: str) -> str:
        """
        Extract text from image using Tesseract
        
        Args:
            image_data: Base64 encoded image string
            
        Returns:
            Extracted text, empty string if extraction fails
        """
        try:
            import pytesseract
            from PIL import Image
            
            # Decode base64 image
            if image_data.startswith('data:image'):
                # Remove data URL prefix if present
                image_data = image_data.split(',')[1]
            
            image_bytes = base64.b64decode(image_data)
            image = Image.open(BytesIO(image_bytes))
            
            # Perform OCR
            text = pytesseract.image_to_string(
                image,
                lang=self.language,
                config='--psm 6'  # Assume uniform block of text
            )
            
            # Clean up extracted text
            return self._clean_text(text)
            
        except Exception as e:
            # Log error but don't raise - OCR failure shouldn't break the app
            print(f"OCR extraction failed: {str(e)}")
            return ""
    
    def _clean_text(self, text: str) -> str:
        """Clean and normalize extracted text"""
        if not text:
            return ""
        
        # Remove excessive whitespace
        lines = [line.strip() for line in text.split('\n') if line.strip()]
        cleaned = ' '.join(lines)
        
        # Remove excessive spaces
        import re
        cleaned = re.sub(r'\s+', ' ', cleaned)
        
        return cleaned.strip()


class MockOCRService(IOCRService):
    """
    Mock OCR service for testing and development
    Returns predefined text without actual OCR processing
    """
    
    def __init__(self, mock_text: str = "Mock OCR extracted text"):
        self.mock_text = mock_text
    
    async def extract_text(self, image_data: str) -> str:
        """Return mock text"""
        return self.mock_text

