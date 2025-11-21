# Extension Icons

이 폴더에는 Chrome Extension의 아이콘 파일들이 위치합니다.

## 필요한 아이콘 파일

- `icon16.png` - 16x16 픽셀
- `icon48.png` - 48x48 픽셀  
- `icon128.png` - 128x128 픽셀

## 임시 아이콘 생성 방법

개발 중에는 다음 방법으로 임시 아이콘을 생성할 수 있습니다:

### Python으로 생성:

```python
from PIL import Image, ImageDraw, ImageFont

def create_icon(size, filename):
    # Create purple gradient background
    img = Image.new('RGB', (size, size), color='#667eea')
    draw = ImageDraw.Draw(img)
    
    # Draw simple book emoji or text
    draw.text((size//4, size//4), "📚", fill='white')
    
    img.save(filename)

create_icon(16, 'icon16.png')
create_icon(48, 'icon48.png')
create_icon(128, 'icon128.png')
```

### 또는 온라인 도구 사용:

- https://www.favicon-generator.org/
- https://favicon.io/

## 프로덕션용 아이콘

프로덕션 배포 시에는 전문 디자이너가 제작한 아이콘을 사용하세요.


