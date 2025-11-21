#!/usr/bin/env python3
"""
Galmuri Diary Backend - Run Script
Starts the FastAPI server
"""
import os
import sys
from pathlib import Path

# Add backend directory to Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

import uvicorn
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Server configuration
HOST = os.getenv("API_HOST", "0.0.0.0")
PORT = int(os.getenv("API_PORT", "8000"))
RELOAD = os.getenv("API_RELOAD", "true").lower() == "true"


def main():
    """Run the FastAPI server"""
    print("=" * 60)
    print("🚀 Galmuri Diary Backend Server")
    print("=" * 60)
    print(f"📡 Server: http://{HOST}:{PORT}")
    print(f"📚 API Docs: http://{HOST}:{PORT}/docs")
    print(f"🔄 Auto-reload: {RELOAD}")
    print("=" * 60)
    print("\nPress Ctrl+C to stop the server\n")
    
    try:
        uvicorn.run(
            "presentation.main:app",
            host=HOST,
            port=PORT,
            reload=RELOAD,
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped gracefully")
        sys.exit(0)


if __name__ == "__main__":
    main()


