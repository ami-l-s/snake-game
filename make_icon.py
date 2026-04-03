"""
Generates Assets/icon.png — 🐍 emoji on app background color #1A1A2E
"""
from PIL import Image, ImageDraw, ImageFont
import os

size = 1024
img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Rounded background matching AppTheme.background = #1A1A2E
draw.rounded_rectangle([0, 0, size, size], radius=200, fill=(26, 26, 46, 255))

# Use Windows Segoe UI Emoji font for the snake emoji
font_path = "C:/Windows/Fonts/seguiemj.ttf"
font_size = 680

try:
    font = ImageFont.truetype(font_path, font_size)
    emoji = "🐍"
    bbox = draw.textbbox((0, 0), emoji, font=font, embedded_color=True)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (size - w) // 2 - bbox[0]
    y = (size - h) // 2 - bbox[1] - 20  # slight upward nudge
    draw.text((x, y), emoji, font=font, embedded_color=True)
    print("Drew emoji with Segoe UI Emoji font")
except Exception as e:
    print(f"Font failed: {e} — using fallback snake drawing")
    # Fallback: hand-drawn snake
    segs = [
        (512,380),(412,380),(312,380),(312,480),
        (412,480),(512,480),(612,480),(612,580),
        (512,580),(412,580),(312,580),
    ]
    r = 58
    body = (155, 148, 255, 255)
    head = (108, 99, 255, 255)
    for i, (cx, cy) in enumerate(segs):
        c = head if i == 0 else body
        draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=c)
    # Eyes
    draw.ellipse([535,355,558,378], fill=(255,255,255,255))
    draw.ellipse([544,361,553,372], fill=(0,0,0,255))
    draw.ellipse([566,355,589,378], fill=(255,255,255,255))
    draw.ellipse([575,361,584,372], fill=(0,0,0,255))
    # Tongue
    draw.line([(512,322),(512,295)], fill=(255,80,80,255), width=8)
    draw.line([(512,295),(495,278)], fill=(255,80,80,255), width=6)
    draw.line([(512,295),(529,278)], fill=(255,80,80,255), width=6)

os.makedirs("Assets", exist_ok=True)
img.save("Assets/icon.png")
print("Saved Assets/icon.png")
