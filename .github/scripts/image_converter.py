from pathlib import Path
from PIL import Image
import os

# Target sizes and folders
sizes = {
    "800x600": 800,
    "400x300": 400,
    "200x150": 200,
    "100x75": 100
}

def convert_and_resize(image_path, output_dir):
    with Image.open(image_path) as img:
        for folder, target_width in sizes.items():
            # Aspect Ratio Maintain
            w_percent = target_width / float(img.size[0])
            target_height = int((float(img.size[1]) * float(w_percent)))
            
            # Resize image
            img_resized = img.resize((target_width, target_height), Image.LANCZOS)

            # Convert to webp
            output_path = output_dir / folder / f"{image_path.stem}.webp"
            output_path.parent.mkdir(parents=True, exist_ok=True)
            img_resized.save(output_path, "WEBP")

def main():
    base_input = Path("images")
    base_output = Path("resized")

    if not base_input.exists():
        print("No 'images' folder found.")
        return

    for image_file in base_input.glob("*.*"):
        if image_file.suffix.lower() not in [".jpg", ".jpeg", ".png", ".bmp", ".tiff", ".webp"]:
            continue
        convert_and_resize(image_file, base_output)

if __name__ == "__main__":
    main()
