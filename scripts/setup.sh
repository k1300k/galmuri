#!/bin/bash

# Galmuri Diary Setup Script
# Sets up the development environment

set -e  # Exit on error

echo "============================================================"
echo "🚀 Galmuri Diary - Setup Script"
echo "============================================================"
echo ""

# Check Python version
echo "📋 Checking Python version..."
python3 --version || { echo "❌ Python 3 is required"; exit 1; }

# Create virtual environment
echo "🔨 Creating virtual environment..."
cd backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✅ Virtual environment created"
else
    echo "ℹ️  Virtual environment already exists"
fi

# Activate virtual environment
echo "⚡ Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "============================================================"
echo "✅ Backend setup complete!"
echo "============================================================"
echo ""

# Check for Tesseract
echo "🔍 Checking for Tesseract OCR..."
if command -v tesseract &> /dev/null; then
    echo "✅ Tesseract is installed"
    tesseract --version | head -1
else
    echo "⚠️  Tesseract is not installed"
    echo ""
    echo "To install Tesseract:"
    echo "  macOS:   brew install tesseract tesseract-lang"
    echo "  Ubuntu:  sudo apt-get install tesseract-ocr tesseract-ocr-kor"
    echo ""
fi

# Create extension icons
echo ""
echo "🎨 Creating extension icons..."
cd ..
python3 scripts/create_icons.py

echo ""
echo "============================================================"
echo "✅ Setup Complete!"
echo "============================================================"
echo ""
echo "Next steps:"
echo "  1. Start the backend server:"
echo "     cd backend && source venv/bin/activate && python run.py"
echo ""
echo "  2. Load the extension in Chrome:"
echo "     - Open chrome://extensions/"
echo "     - Enable 'Developer mode'"
echo "     - Click 'Load unpacked'"
echo "     - Select the 'extension' folder"
echo ""
echo "  3. Configure the extension:"
echo "     - Click the extension icon"
echo "     - Go to Settings"
echo "     - Enter your API Key and User ID"
echo ""
echo "============================================================"


