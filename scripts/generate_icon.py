#!/usr/bin/env python3
"""
Generates macOS and iOS app icons for Budget for Retirement.

Usage:
    python3 scripts/generate_icon.py

Requirements:
    pip install Pillow
"""

from PIL import Image, ImageDraw
from pathlib import Path
import math

# Color palette - warm gold/amber for retirement/wealth
GOLD = (218, 165, 32)           # #DAA520
GOLD_LIGHT = (255, 215, 0)      # #FFD700
GOLD_DARK = (184, 134, 11)      # #B8860B
DARK_BG = (28, 35, 45)          # Dark blue-gray
DARK_BG_LIGHT = (45, 55, 72)    # Lighter blue-gray
SUCCESS_GREEN = (72, 187, 120)  # Growth indicator


def create_icon(size: int) -> Image.Image:
    """Create a single icon at the specified size."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    radius = size // 2 - max(1, size // 64)
    
    # Draw circular gradient background (dark professional blue-gray)
    for r in range(radius, 0, -1):
        ratio = r / radius
        color = tuple(
            int(DARK_BG[i] + (DARK_BG_LIGHT[i] - DARK_BG[i]) * (1 - ratio))
            for i in range(3)
        ) + (255,)
        draw.ellipse([center - r, center - r, center + r, center + r], fill=color)
    
    # Draw rising chart line (representing growth toward retirement)
    margin = size * 0.2
    chart_left = int(margin)
    chart_right = int(size - margin)
    chart_bottom = int(size * 0.72)
    chart_top = int(size * 0.28)
    
    # Chart points - exponential growth curve
    num_points = 6
    points = []
    for i in range(num_points):
        x = chart_left + (chart_right - chart_left) * i / (num_points - 1)
        # Exponential curve
        progress = i / (num_points - 1)
        y = chart_bottom - (chart_bottom - chart_top) * (progress ** 1.8)
        points.append((x, y))
    
    # Draw line with thickness
    line_width = max(2, size // 20)
    for i in range(len(points) - 1):
        x1, y1 = points[i]
        x2, y2 = points[i + 1]
        
        # Gradient color along the line
        ratio = i / (len(points) - 2)
        r = int(GOLD_DARK[0] + (GOLD_LIGHT[0] - GOLD_DARK[0]) * ratio)
        g = int(GOLD_DARK[1] + (GOLD_LIGHT[1] - GOLD_DARK[1]) * ratio)
        b = int(GOLD_DARK[2] + (GOLD_LIGHT[2] - GOLD_DARK[2]) * ratio)
        
        draw.line([(x1, y1), (x2, y2)], fill=(r, g, b, 255), width=line_width)
    
    # Draw circles at data points
    dot_radius = max(2, size // 16)
    for i, (x, y) in enumerate(points):
        ratio = i / (len(points) - 1)
        r = int(GOLD_DARK[0] + (GOLD_LIGHT[0] - GOLD_DARK[0]) * ratio)
        g = int(GOLD_DARK[1] + (GOLD_LIGHT[1] - GOLD_DARK[1]) * ratio)
        b = int(GOLD_DARK[2] + (GOLD_LIGHT[2] - GOLD_DARK[2]) * ratio)
        draw.ellipse(
            [x - dot_radius, y - dot_radius, x + dot_radius, y + dot_radius],
            fill=(r, g, b, 255)
        )
    
    # Draw upward arrow at end point indicating success/growth
    last_x, last_y = points[-1]
    arrow_size = max(3, size // 10)
    if size >= 64:
        # Arrow pointing up-right
        arrow_tip_x = last_x + arrow_size * 0.3
        arrow_tip_y = last_y - arrow_size * 0.5
        draw.polygon([
            (arrow_tip_x, arrow_tip_y),
            (arrow_tip_x - arrow_size * 0.4, arrow_tip_y + arrow_size * 0.3),
            (arrow_tip_x - arrow_size * 0.15, arrow_tip_y + arrow_size * 0.3),
            (arrow_tip_x - arrow_size * 0.15, arrow_tip_y + arrow_size * 0.7),
            (arrow_tip_x + arrow_size * 0.15, arrow_tip_y + arrow_size * 0.7),
            (arrow_tip_x + arrow_size * 0.15, arrow_tip_y + arrow_size * 0.3),
            (arrow_tip_x + arrow_size * 0.4, arrow_tip_y + arrow_size * 0.3),
        ], fill=(*SUCCESS_GREEN, 255))
    
    return img


def generate_macos_icons():
    """Generate icons for all required macOS sizes."""
    script_dir = Path(__file__).parent
    output_dir = script_dir.parent / 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
    
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    for size in sizes:
        icon = create_icon(size)
        output_path = output_dir / f'app_icon_{size}.png'
        icon.save(output_path, 'PNG')
        print(f'✓ macOS {size}x{size} → {output_path.name}')
    
    print(f'\nmacOS icons saved to: {output_dir}')


def generate_ios_icons():
    """Generate icons for all required iOS sizes."""
    script_dir = Path(__file__).parent
    output_dir = script_dir.parent / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    
    # iOS icon sizes based on Contents.json
    # Format: (base_size, scale) -> actual_size
    ios_sizes = [
        (20, 1), (20, 2), (20, 3),  # 20, 40, 60
        (29, 1), (29, 2), (29, 3),  # 29, 58, 87
        (40, 1), (40, 2), (40, 3),  # 40, 80, 120
        (60, 2), (60, 3),           # 120, 180
        (76, 1), (76, 2),           # 76, 152
        (83.5, 2),                  # 167
        (1024, 1),                  # 1024
    ]
    
    for base_size, scale in ios_sizes:
        actual_size = int(base_size * scale)
        icon = create_icon(actual_size)
        
        # Generate filename based on iOS naming convention
        if base_size == 83.5:
            filename = f'Icon-App-83.5x83.5@2x.png'
        else:
            scale_str = '@1x' if scale == 1 else f'@{scale}x'
            filename = f'Icon-App-{int(base_size)}x{int(base_size)}{scale_str}.png'
        
        output_path = output_dir / filename
        icon.save(output_path, 'PNG')
        print(f'✓ iOS {actual_size}x{actual_size} → {filename}')
    
    print(f'\niOS icons saved to: {output_dir}')


def generate_all_icons():
    """Generate icons for both macOS and iOS."""
    print('Generating macOS icons...')
    generate_macos_icons()
    print('\nGenerating iOS icons...')
    generate_ios_icons()
    print('\n✓ All icons generated successfully!')


if __name__ == '__main__':
    generate_all_icons()

