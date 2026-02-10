#!/usr/bin/env python3
"""
글래스모피즘 스타일의 ClipboardManager 앱 아이콘 생성 스크립트
"""

from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math

def create_glassmorphism_icon(size):
    """글래스모피즘 스타일 아이콘 생성"""

    # 투명 배경 이미지 생성
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 배경 그라데이션 (진한 보라-파랑-핑크)
    for y in range(size):
        # 그라데이션 계산
        ratio = y / size

        # 진한 보라(120, 80, 200) -> 진한 파랑(80, 120, 220) -> 진한 핑크(200, 80, 160)
        if ratio < 0.5:
            r_ratio = ratio * 2
            r = int(120 + (80 - 120) * r_ratio)
            g = int(80 + (120 - 80) * r_ratio)
            b = int(200 + (220 - 200) * r_ratio)
        else:
            r_ratio = (ratio - 0.5) * 2
            r = int(80 + (200 - 80) * r_ratio)
            g = int(120 + (80 - 120) * r_ratio)
            b = int(220 + (160 - 220) * r_ratio)

        # 배경 원 그리기
        alpha = 255
        draw.line([(0, y), (size, y)], fill=(r, g, b, alpha))

    # 원형으로 마스크 (macOS 아이콘 스타일)
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.ellipse([0, 0, size, size], fill=255)

    # 블러 효과 제거 (명확한 표현을 위해)

    # 클립보드 형태 그리기
    margin = size // 6
    clip_width = size - margin * 2
    clip_height = int(clip_width * 1.2)
    clip_top = (size - clip_height) // 2

    # 클립보드 본체 (불투명한 흰색 + 그림자)
    board_rect = [
        margin,
        clip_top,
        margin + clip_width,
        clip_top + clip_height
    ]

    # 그림자 효과 (여러 겹으로 부드럽게)
    shadow_offset = size // 40
    for i in range(3, 0, -1):
        shadow_alpha = 15 * i
        offset = shadow_offset * i
        draw.rounded_rectangle(
            [board_rect[0] + offset, board_rect[1] + offset,
             board_rect[2] + offset, board_rect[3] + offset],
            radius=size // 15,
            fill=(0, 0, 0, shadow_alpha)
        )

    # 클립보드 본체 - frosted glass 효과 (반투명 흰색)
    draw.rounded_rectangle(
        board_rect,
        radius=size // 15,
        fill=(255, 255, 255, 200)
    )

    # 클립보드 테두리 (밝은 그라데이션)
    border_width = max(2, size // 100)
    draw.rounded_rectangle(
        board_rect,
        radius=size // 15,
        outline=(255, 255, 255, 220),
        width=border_width
    )

    # 클립 부분 (상단 중앙) - 더 두드러지게
    clip_width_small = clip_width // 3
    clip_height_small = size // 10
    clip_x = margin + (clip_width - clip_width_small) // 2
    clip_y = clip_top - clip_height_small // 3

    # 클립 그림자
    draw.rounded_rectangle(
        [clip_x + shadow_offset, clip_y + shadow_offset,
         clip_x + clip_width_small + shadow_offset, clip_y + clip_height_small + shadow_offset],
        radius=size // 30,
        fill=(0, 0, 0, 40)
    )

    # 클립 본체
    draw.rounded_rectangle(
        [clip_x, clip_y, clip_x + clip_width_small, clip_y + clip_height_small],
        radius=size // 30,
        fill=(255, 255, 255, 230)
    )

    # 클립 테두리
    draw.rounded_rectangle(
        [clip_x, clip_y, clip_x + clip_width_small, clip_y + clip_height_small],
        radius=size // 30,
        outline=(255, 255, 255, 255),
        width=max(1, size // 200)
    )

    # 클립 하이라이트
    draw.rounded_rectangle(
        [clip_x + size // 60, clip_y + size // 80,
         clip_x + clip_width_small - size // 60, clip_y + clip_height_small // 3],
        radius=size // 50,
        fill=(255, 255, 255, 120)
    )

    # 클립보드 안의 라인들 (텍스트 표현) - 더 명확하게
    line_margin = margin + clip_width // 6
    line_width = clip_width - clip_width // 3
    line_spacing = size // 18
    line_start_y = clip_top + size // 6

    # 그라데이션 라인
    for i in range(4):
        y = line_start_y + i * line_spacing
        line_h = max(2, size // 60)
        line_w = line_width if i < 3 else line_width * 2 // 3

        # 라인 그림자
        draw.rounded_rectangle(
            [line_margin + 1, y + 1, line_margin + line_w + 1, y + line_h + 1],
            radius=size // 150,
            fill=(0, 0, 0, 20)
        )

        # 라인 본체 (밝은 보라-파랑 그라데이션)
        ratio = i / 4
        r = int(180 + (120 - 180) * ratio)
        g = int(160 + (200 - 160) * ratio)
        b = 255
        draw.rounded_rectangle(
            [line_margin, y, line_margin + line_w, y + line_h],
            radius=size // 150,
            fill=(r, g, b, 200)
        )

    # 테두리 하이라이트 (글래스 효과)
    highlight = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    highlight_draw = ImageDraw.Draw(highlight)

    # 상단 하이라이트 (빛 반사)
    for i in range(size // 4):
        alpha = int(80 * (1 - i / (size // 4)))
        highlight_draw.ellipse(
            [size // 4, i, size * 3 // 4, size // 2],
            fill=(255, 255, 255, alpha)
        )

    img = Image.alpha_composite(img, highlight)

    # 원형 마스크 적용
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0), mask)

    # 테두리 그라데이션 (글래스 효과 강화)
    border_width = max(2, size // 80)
    border_mask = Image.new('L', (size, size), 0)
    border_draw = ImageDraw.Draw(border_mask)
    border_draw.ellipse([0, 0, size, size], fill=255)
    border_draw.ellipse([border_width, border_width, size - border_width, size - border_width], fill=0)

    border_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_img)

    # 그라데이션 테두리
    for angle in range(0, 360, 2):
        rad = math.radians(angle)
        ratio = angle / 360

        # 보라-파랑-핑크 그라데이션
        if ratio < 0.33:
            r_ratio = ratio * 3
            r = int(180 + (100 - 180) * r_ratio)
            g = int(100 + (200 - 100) * r_ratio)
            b = 255
        elif ratio < 0.66:
            r_ratio = (ratio - 0.33) * 3
            r = int(100 + (255 - 100) * r_ratio)
            g = int(200 + (100 - 200) * r_ratio)
            b = int(255 + (180 - 255) * r_ratio)
        else:
            r_ratio = (ratio - 0.66) * 3
            r = 255
            g = int(100 + (100 - 100) * r_ratio)
            b = int(180 + (255 - 180) * r_ratio)

        x1 = size // 2 + int((size // 2) * math.cos(rad))
        y1 = size // 2 + int((size // 2) * math.sin(rad))
        x2 = size // 2 + int((size // 2 - border_width * 2) * math.cos(rad))
        y2 = size // 2 + int((size // 2 - border_width * 2) * math.sin(rad))

        border_draw.line([x1, y1, x2, y2], fill=(r, g, b, 180), width=border_width)

    output = Image.alpha_composite(output, border_img)

    return output

def generate_all_icons():
    """모든 필요한 크기의 아이콘 생성"""

    sizes = {
        'icon_16x16.png': 16,
        'icon_16x16@2x.png': 32,
        'icon_32x32.png': 32,
        'icon_32x32@2x.png': 64,
        'icon_128x128.png': 128,
        'icon_128x128@2x.png': 256,
        'icon_256x256.png': 256,
        'icon_256x256@2x.png': 512,
        'icon_512x512.png': 512,
        'icon_512x512@2x.png': 1024,
    }

    output_dir = 'ClipboardManager/ClipboardManager/Assets.xcassets/AppIcon.appiconset'

    print("🎨 글래스모피즘 아이콘 생성 중...")

    for filename, size in sizes.items():
        print(f"  ✓ {filename} ({size}x{size})")
        icon = create_glassmorphism_icon(size)
        icon.save(f"{output_dir}/{filename}", 'PNG')

    print("\n✅ 아이콘 생성 완료!")
    print(f"📁 저장 위치: {output_dir}")

if __name__ == '__main__':
    generate_all_icons()
