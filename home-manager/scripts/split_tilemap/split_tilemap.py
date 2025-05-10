import os
import sys

from PIL import Image


def split_image(columns, rows, image_path):
    try:
        img = Image.open(image_path)
    except IOError as e:
        print(f"Failed to open image: {e}")
        return

    img_width, img_height = img.size
    tile_width = img_width // columns
    tile_height = img_height // rows

    base_name, ext = os.path.splitext(image_path)

    for row in range(rows):
        for col in range(columns):
            left = col * tile_width
            upper = row * tile_height
            right = (col + 1) * tile_width
            lower = (row + 1) * tile_height

            tile = img.crop((left, upper, right, lower))
            tile_filename = f"{base_name}_{row}_{col}{ext}"
            tile.save(tile_filename)
            print(f"Saved {tile_filename}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: split_tilemap.py <columns> <rows> <image_path>")
        sys.exit(1)

    try:
        columns = int(sys.argv[1])
        rows = int(sys.argv[2])
    except ValueError:
        print("Columns and rows must be integers.")
        sys.exit(1)

    image_path = sys.argv[3]
    split_image(columns, rows, image_path)
