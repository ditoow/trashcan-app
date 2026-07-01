"""
Create & deploy Hugging Face Space for TrashScan model inference.
Usage: python scripts/create_hf_space.py
"""

import os
import sys
from pathlib import Path
from huggingface_hub import HfApi, create_repo, upload_file

HF_TOKEN = os.environ.get("HF_TOKEN")
USERNAME = "ditoow"
MODEL_DIR = Path("/Users/ditoghifari/Documents/development/TrashApp/Model")

VARIANTS = {
    "trashscan8n": "mobile_model_package_yolov8n_v2",
    "trashscan8s": "mobile_model_package_yolov8s_v2",
    "trashscan8m": "mobile_model_package_yolov8m_v2",
}

SERVER_SCRIPT = (Path(__file__).parent / "hf_space_server.py").read_text()

REQUIREMENTS = """fastapi
uvicorn
onnxruntime
pillow
numpy
"""

SPACE_README = """---
title: TrashScan {variant}
emoji: 🗑️
colorFrom: purple
colorTo: indigo
sdk: docker
pinned: false
---

# TrashScan {variant}

YOLOv8 {variant} ONNX model server for waste detection.

## API

`POST /detect` — send image bytes, get detections back.
"""

DOCKERFILE = """
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY best.onnx .
COPY hf_space_server.py .

CMD ["uvicorn", "hf_space_server:app", "--host", "0.0.0.0", "--port", "7860"]
"""

def create_space(api: HfApi, repo_name: str, variant_dir: str):
    repo_id = f"{USERNAME}/{repo_name}"
    print(f"\n=== Creating Space {repo_id} ===")

    try:
        create_repo(
            repo_id,
            repo_type="space",
            exist_ok=True,
            private=False,
            space_sdk="docker",
        )
        print(f"  Space created/found: {repo_id}")
    except Exception as e:
        print(f"  Error: {e}")
        return

    upload_file(
        token=HF_TOKEN,
        path_or_fileobj=SERVER_SCRIPT.encode(),
        path_in_repo="hf_space_server.py",
        repo_id=repo_id,
        repo_type="space",
    )
    print("  Uploaded hf_space_server.py")

    upload_file(
        token=HF_TOKEN,
        path_or_fileobj=REQUIREMENTS.encode(),
        path_in_repo="requirements.txt",
        repo_id=repo_id,
        repo_type="space",
    )
    print("  Uploaded requirements.txt")

    upload_file(
        token=HF_TOKEN,
        path_or_fileobj=DOCKERFILE.encode(),
        path_in_repo="Dockerfile",
        repo_id=repo_id,
        repo_type="space",
    )
    print("  Uploaded Dockerfile")

    readme = SPACE_README.format(variant=variant_dir.replace("mobile_model_package_", "").replace("_v2", "").upper())
    upload_file(
        token=HF_TOKEN,
        path_or_fileobj=readme.encode(),
        path_in_repo="README.md",
        repo_id=repo_id,
        repo_type="space",
    )
    print("  Uploaded README.md")

    onnx_path = MODEL_DIR / variant_dir / "best.onnx"
    if onnx_path.exists():
        upload_file(
            token=HF_TOKEN,
            path_or_fileobj=str(onnx_path),
            path_in_repo="best.onnx",
            repo_id=repo_id,
            repo_type="space",
        )
        print(f"  Uploaded best.onnx ({onnx_path})")
    else:
        print(f"  WARNING: {onnx_path} not found!")

    print(f"  ✅ Space ready: https://huggingface.co/spaces/{repo_id}")


def main():
    if not HF_TOKEN:
        print("ERROR: Set HF_TOKEN env variable")
        sys.exit(1)

    api = HfApi()

    for repo_name, variant_dir in VARIANTS.items():
        create_space(api, repo_name, variant_dir)

    print("\n=== All Spaces created! ===")
    for repo_name in VARIANTS:
        print(f"  https://huggingface.co/spaces/{USERNAME}/{repo_name}")
    print("\nAfter first deployment, update Flutter app URL to https://{username}-{repo}.hf.space/detect")


if __name__ == "__main__":
    main()
