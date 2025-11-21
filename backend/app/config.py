"""Application configuration using Pydantic Settings"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Database
    DATABASE_URL: str = "sqlite+aiosqlite:///./galmuri.db"
    
    # API Settings
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_RELOAD: bool = True
    API_TITLE: str = "Galmuri Diary API"
    API_VERSION: str = "1.0.0"
    
    # Security
    API_KEY_SALT: str = "default-salt-change-in-production"
    
    # OCR Settings
    TESSERACT_CMD: str = "/usr/local/bin/tesseract"
    OCR_LANGUAGE: str = "kor+eng"
    OCR_TIMEOUT: int = 30  # seconds
    
    # CORS
    CORS_ORIGINS: list[str] = ["*"]
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True
    )


settings = Settings()

