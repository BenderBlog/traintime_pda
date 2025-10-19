#!/usr/bin/env python3

import sys
import json
from pathlib import Path
from PIL import Image


def calculate_pixel_fnv1a(file_path):
    image = Image.open(file_path).convert("RGBA")
    
    pixel_bytes = []
    pixels = image.load()
    
    for y in range(20):
        for x in range(50):
            pixel = pixels[x, y]
            r, g, b, a = pixel[0], pixel[1], pixel[2], pixel[3]
            
            if a == 255:
                pixel_bytes.extend([r, g, b])
    
    hash_value = 0x811C9DC5
    for byte in pixel_bytes:
        hash_value ^= byte
        hash_value = (hash_value * 0x01000193) & 0xFFFFFFFF
    
    return hash_value


directory_path = sys.argv[1]
output_path = sys.argv[2] if len(sys.argv) > 2 else "score_hashes.json"

directory = Path(directory_path)
file_hashes = {}

for file_path in directory.rglob('*'):
    if file_path.suffix.lower() in {'.png', '.jpg', '.jpeg', '.bmp', '.gif'}:
        relative_path = file_path.relative_to(directory)
        file_key = str(relative_path.with_suffix(''))
        
        print(f"Processing: {relative_path}")
        hash_value = calculate_pixel_fnv1a(str(file_path))
        file_hashes[file_key] = hash_value

with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(file_hashes, f, ensure_ascii=False, separators=(',', ':'))

print(f"\nProcessed {len(file_hashes)} files")
print(f"Saved to: {Path(output_path).absolute()}")
