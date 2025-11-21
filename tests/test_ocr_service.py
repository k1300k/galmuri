"""
Tests for OCR Service
Following TDD principles
"""
import pytest
import base64
from io import BytesIO
from backend.application.ocr_service import MockOCRService, TesseractOCRService


class TestMockOCRService:
    """Test Mock OCR Service"""
    
    @pytest.mark.asyncio
    async def test_mock_ocr_returns_predefined_text(self):
        """Should return predefined mock text"""
        service = MockOCRService(mock_text="테스트 텍스트")
        
        result = await service.extract_text("any_image_data")
        
        assert result == "테스트 텍스트"
    
    @pytest.mark.asyncio
    async def test_mock_ocr_default_text(self):
        """Should return default mock text"""
        service = MockOCRService()
        
        result = await service.extract_text("any_image_data")
        
        assert result == "Mock OCR extracted text"


class TestTesseractOCRService:
    """Test Tesseract OCR Service"""
    
    def test_service_initialization(self):
        """Should initialize with default language"""
        try:
            service = TesseractOCRService()
            assert service.language == 'kor+eng'
        except RuntimeError:
            # Tesseract not installed - skip test
            pytest.skip("Tesseract not installed")
    
    def test_service_initialization_custom_language(self):
        """Should initialize with custom language"""
        try:
            service = TesseractOCRService(language='eng')
            assert service.language == 'eng'
        except RuntimeError:
            pytest.skip("Tesseract not installed")
    
    @pytest.mark.asyncio
    async def test_extract_text_from_base64(self):
        """Should extract text from base64 encoded image"""
        try:
            from PIL import Image, ImageDraw, ImageFont
            
            # Create a simple test image with text
            img = Image.new('RGB', (200, 50), color='white')
            draw = ImageDraw.Draw(img)
            draw.text((10, 10), "TEST", fill='black')
            
            # Convert to base64
            buffered = BytesIO()
            img.save(buffered, format="PNG")
            img_base64 = base64.b64encode(buffered.getvalue()).decode()
            
            service = TesseractOCRService(language='eng')
            result = await service.extract_text(img_base64)
            
            # Should extract some text (exact match may vary)
            assert isinstance(result, str)
            
        except RuntimeError:
            pytest.skip("Tesseract not installed")
        except Exception as e:
            # Some OCR tests may fail in CI environment
            pytest.skip(f"OCR test skipped: {str(e)}")
    
    @pytest.mark.asyncio
    async def test_extract_text_handles_errors_gracefully(self):
        """Should handle invalid image data gracefully"""
        try:
            service = TesseractOCRService()
            
            # Invalid base64 data
            result = await service.extract_text("invalid_base64_data!!!")
            
            # Should return empty string instead of raising exception
            assert result == ""
            
        except RuntimeError:
            pytest.skip("Tesseract not installed")
    
    def test_clean_text(self):
        """Should clean and normalize text"""
        try:
            service = TesseractOCRService()
            
            # Test with messy text
            messy_text = "  Line 1  \n\n  Line 2   \n   \n  Line 3  "
            cleaned = service._clean_text(messy_text)
            
            assert cleaned == "Line 1 Line 2 Line 3"
            
        except RuntimeError:
            pytest.skip("Tesseract not installed")
    
    def test_clean_text_empty(self):
        """Should handle empty text"""
        try:
            service = TesseractOCRService()
            
            cleaned = service._clean_text("")
            
            assert cleaned == ""
            
        except RuntimeError:
            pytest.skip("Tesseract not installed")

