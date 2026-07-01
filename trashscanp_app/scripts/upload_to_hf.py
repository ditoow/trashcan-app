"""
Upload YOLOv8 ONNX models to Hugging Face Hub.

Usage:
    export HF_TOKEN=hf_your_token_here
    python scripts/upload_to_hf.py --username ditoow
"""

import os
import argparse
from pathlib import Path
from huggingface_hub import HfApi, create_repo, upload_file

MODEL_DIR = Path("/Users/ditoghifari/Documents/development/TrashApp/Model")

VARIANTS = {
    "trashscan8n": "mobile_model_package_yolov8n_v2",
    "trashscan8s": "mobile_model_package_yolov8s_v2",
    "trashscan8m": "mobile_model_package_yolov8m_v2",
}

README_TEMPLATE = """
---
language: en
license: mit
tags:
  - yolov8
  - object-detection
  - waste-classification
library_name: onnx
pipeline_tag: object-detection
---

# {repo_name}

YOLOv8 {variant} ONNX model for waste classification.

## Classes

| Index | Class |
|-------|-------|
| 0     | paper |
| 1     | plastic |
| 2     | metal |
| 3     | organic |
| 4     | other |

## Usage

```python
import onnxruntime
import numpy as np
from PIL import Image

session = onnxruntime.InferenceSession("best.onnx")
input_name = session.get_inputs()[0].name
# Input: [1, 3, 640, 640] normalized float32
# Output: [1, 9, 8400] = [cx, cy, w, h, p0, p1, p2, p3, p4]
```

## Model Specs

- Input size: 640x640
- Format: ONNX
- Confidence threshold: 0.25
- IoU threshold: 0.5
"""


def upload_variant(api: HfApi, username: str, repo_name: str, variant_dir: str):
    repo_id = f"{username}/{repo_name}"
    
    print(f"\n=== Uploading {repo_id} ===")
    
    try:
        create_repo(repo_id, exist_ok=True, private=False)
        print(f"  Repo created/found: {repo_id}")
    except Exception as e:
        print(f"  Note: {e}")
    
    variant_path = MODEL_DIR / variant_dir
    files_to_upload = ["best.onnx", "deployment_info.json", "data.yaml"]
    
    for filename in files_to_upload:
        file_path = variant_path / filename
        if file_path.exists():
            print(f"  Uploading {filename}...")
            upload_file(
                token=os.environ["HF_TOKEN"],
                path_or_fileobj=str(file_path),
                path_in_repo=filename,
                repo_id=repo_id,
            )
            print(f"    Done")
        else:
            print(f"  Skipping {filename} (not found)")
    
    # Upload README
    readme_content = README_TEMPLATE.format(
        repo_name=repo_name, variant=variant_dir
    )
    readme_path = "/tmp/hf_readme.md"
    with open(readme_path, "w") as f:
        f.write(readme_content)
    
    upload_file(
        token=os.environ["HF_TOKEN"],
        path_or_fileobj=readme_path,
        path_in_repo="README.md",
        repo_id=repo_id,
    )
    print(f"  README uploaded")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--username", default="ditoow")
    parser.add_argument("--variant", choices=list(VARIANTS.keys()) + ["all"], default="all")
    args = parser.parse_args()
    
    api = HfApi()
    
    if args.variant == "all":
        for repo_name, variant_dir in VARIANTS.items():
            upload_variant(api, args.username, repo_name, variant_dir)
    else:
        upload_variant(api, args.username, args.variant, VARIANTS[args.variant])
    
    print("\n=== All done! ===")
    print(f"Models available at: https://huggingface.co/{args.username}")
    for repo_name in VARIANTS:
        print(f"  https://huggingface.co/{args.username}/{repo_name}")


if __name__ == "__main__":
    main()
