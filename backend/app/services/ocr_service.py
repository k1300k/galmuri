"""OCR Service using Tesseract for text extraction from images"""
import base64
import io
import logging
from typing import Optional
from PIL import Image
import pytesseract
from app.config import settings

logger = logging.getLogger(__name__)


class OCRService:
    """
    Service for extracting text from images using Tesseract OCR
    
    Features:
    - Async processing support
    - Multi-language support (Korean + English)
    - Base64 image handling
    - Error handling with fallback
    """
    
    def __init__(self):
        """Initialize OCR service with Tesseract configuration"""
        # Set Tesseract command path if configured
        if settings.TESSERACT_CMD:
            pytesseract.pytesseract.tesseract_cmd = settings.TESSERACT_CMD
    
    def extract_text_from_base64(self, base64_image: str) -> tuple[Optional[str], bool]:
        """
        Extract text from base64 encoded image
        
        Args:
            base64_image: Base64 encoded image string (with or without data URL prefix)
            
        Returns:
            Tuple of (extracted_text, success)
            - extracted_text: Extracted text or None if failed
            - success: True if extraction succeeded, False otherwise
        """
        try:
            # Remove data URL prefix if present (e.g., "data:image/png;base64,")
            if "," in base64_image:
                base64_image = base64_image.split(",", 1)[1]
            
            # Decode base64 to bytes
            image_bytes = base64.b64decode(base64_image)
            
            # Open image using PIL
            image = Image.open(io.BytesIO(image_bytes))
            
            # Extract text using Tesseract
            extracted_text = self._extract_text_from_image(image)
            
            if extracted_text and len(extracted_text.strip()) > 0:
                logger.info(f"OCR extraction successful. Extracted {len(extracted_text)} characters.")
                return extracted_text.strip(), True
            else:
                logger.warning("OCR extraction returned empty text")
                return None, False
                
        except Exception as e:
            logger.error(f"OCR extraction failed: {str(e)}")
            return None, False
    
    def _extract_text_from_image(self, image: Image.Image) -> str:
        """
        Internal method to extract text from PIL Image object
        
        Args:
            image: PIL Image object
            
        Returns:
            Extracted text string
        """
        # Convert image to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Configure Tesseract
        custom_config = f'--oem 3 --psm 6'  # OEM 3: Default, PSM 6: Assume uniform text block
        
        # Extract text with language settings
        text = pytesseract.image_to_string(
            image,
            lang=settings.OCR_LANGUAGE,
            config=custom_config
        )
        
        return text
    
    def extract_text_from_file(self, file_path: str) -> tuple[Optional[str], bool]:
        """
        Extract text from image file
        
        Args:
            file_path: Path to image file
            
        Returns:
            Tuple of (extracted_text, success)
        """
        try:
            image = Image.open(file_path)
            extracted_text = self._extract_text_from_image(image)
            
            if extracted_text and len(extracted_text.strip()) > 0:
                return extracted_text.strip(), True
            else:
                return None, False
                
        except Exception as e:
            logger.error(f"OCR extraction from file failed: {str(e)}")
            return None, False

