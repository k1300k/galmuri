#!/usr/bin/env python3
"""
Create simple placeholder icons for Chrome Extension
"""
from PIL import Image, ImageDraw, ImageFont
import os

# Output directory
ASSETS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'extension', 'assets')

# Ensure directory exists
os.makedirs(ASSETS_DIR, exist_ok=True)


def create_gradient_background(size):
    """Create a purple gradient background"""
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)
    
    # Create gradient from #667eea to #764ba2
    for y in range(size):
        # Calculate color for this row
        ratio = y / size
        r = int(102 + (118 - 102) * ratio)
        g = int(126 + (75 - 126) * ratio)
        b = int(234 + (162 - 234) * ratio)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b))
    
    return img


def add_emoji_or_text(img, size):
    """Add icon content (book emoji or text)"""
    draw = ImageDraw.Draw(img)
    
    # Try to add text
    try:
        # For larger icons, try to use a font
        if size >= 48:
            font_size = size // 3
            # Try to load a system font
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", font_size)
            except:
                font = ImageFont.load_default()
            
            text = "📚"
            
            # Get text bounding box
            bbox = draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            
            # Center the text
            x = (size - text_width) // 2
            y = (size - text_height) // 2 - bbox[1]
            
            draw.text((x, y), text, fill='white', font=font)
        else:
            # For small icons, just draw a simple book shape
            margin = size // 4
            draw.rectangle(
                [(margin, margin), (size - margin, size - margin)],
                fill='white',
                outline='white',
                width=2
            )
            # Draw pages line
            center_x = size // 2
            draw.line(
                [(center_x, margin), (center_x, size - margin)],
                fill='#667eea',
                width=2
            )
            
    except Exception as e:
        print(f"Note: Could not add emoji/text: {e}")
        # Fallback: simple white circle
        margin = size // 4
        draw.ellipse(
            [(margin, margin), (size - margin, size - margin)],
            fill='white'
        )
    
    return img


def create_icon(size, filename):
    """Create an icon with the specified size"""
    print(f"Creating {filename} ({size}x{size})...")
    
    # Create gradient background
    img = create_gradient_background(size)
    
    # Add icon content
    img = add_emoji_or_text(img, size)
    
    # Save
    output_path = os.path.join(ASSETS_DIR, filename)
    img.save(output_path, 'PNG')
    
    print(f"✅ Created: {output_path}")


def main():
    """Create all required icons"""
    print("=" * 60)
    print("🎨 Creating Galmuri Diary Extension Icons")
    print("=" * 60)
    print()
    
    # Create icons in required sizes
    sizes = [
        (16, 'icon16.png'),
        (48, 'icon48.png'),
        (128, 'icon128.png')
    ]
    
    for size, filename in sizes:
        create_icon(size, filename)
    
    print()
    print("=" * 60)
    print("✅ All icons created successfully!")
    print(f"📁 Location: {ASSETS_DIR}")
    print("=" * 60)


if __name__ == "__main__":
    main()


