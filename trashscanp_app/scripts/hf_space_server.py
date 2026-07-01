"""
FastAPI server for Hugging Face Space.
Deploy this to https://huggingface.co/spaces/ditoow/trashscan8n

Usage:
    pip install fastapi uvicorn onnxruntime pillow numpy
    uvicorn hf_space_server:app --host 0.0.0.0 --port 7860
"""

import io
import numpy as np
from PIL import Image
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import onnxruntime as ort

app = FastAPI()

MODEL_PATH = "best.onnx"
session = None
input_name = None
output_name = None

CLASSES = ["paper", "plastic", "metal", "organic", "other"]


@app.on_event("startup")
async def load_model():
    global session, input_name, output_name
    session = ort.InferenceSession(MODEL_PATH)
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name


def preprocess(image: Image.Image) -> np.ndarray:
    orig_w, orig_h = image.size
    scale = 640 / max(orig_w, orig_h)
    new_w = int(orig_w * scale)
    new_h = int(orig_h * scale)
    resized = image.resize((new_w, new_h), Image.LANCZOS)

    canvas = Image.new("RGB", (640, 640), (0, 0, 0))
    dx = (640 - new_w) // 2
    dy = (640 - new_h) // 2
    canvas.paste(resized, (dx, dy))

    img_array = np.array(canvas, dtype=np.float32) / 255.0
    img_array = img_array.transpose(2, 0, 1)
    img_array = np.expand_dims(img_array, axis=0)
    return img_array, scale, dx, dy, orig_w, orig_h


def postprocess(output: np.ndarray, scale, dx, dy, orig_w, orig_h, conf_thresh=0.1, iou_thresh=0.5):
    output = output.squeeze()
    num_classes = len(CLASSES)
    num_boxes = output.shape[1]

    boxes = []
    for i in range(num_boxes):
        cx, cy, w, h = output[0, i], output[1, i], output[2, i], output[3, i]
        scores = output[4:4 + num_classes, i]
        max_conf = float(scores.max())
        if max_conf < conf_thresh:
            continue
        class_id = int(scores.argmax())

        x1 = (cx - w / 2 - dx) / (scale * orig_w)
        y1 = (cy - h / 2 - dy) / (scale * orig_h)
        x2 = (cx + w / 2 - dx) / (scale * orig_w)
        y2 = (cy + h / 2 - dy) / (scale * orig_h)

        x1 = max(0, min(1, x1))
        y1 = max(0, min(1, y1))
        x2 = max(0, min(1, x2))
        y2 = max(0, min(1, y2))

        boxes.append({
            "label": CLASSES[class_id],
            "score": float(max_conf),
            "xmin": float(x1),
            "ymin": float(y1),
            "xmax": float(x2),
            "ymax": float(y2),
        })

    # NMS
    boxes.sort(key=lambda b: b["score"], reverse=True)
    kept = []
    for box in boxes:
        if not any(iou(box, k) > iou_thresh for k in kept):
            kept.append(box)
    return kept


def iou(a, b):
    x1 = max(a["xmin"], b["xmin"])
    y1 = max(a["ymin"], b["ymin"])
    x2 = min(a["xmax"], b["xmax"])
    y2 = min(a["ymax"], b["ymax"])
    inter = max(0, x2 - x1) * max(0, y2 - y1)
    area_a = (a["xmax"] - a["xmin"]) * (a["ymax"] - a["ymin"])
    area_b = (b["xmax"] - b["xmin"]) * (b["ymax"] - b["ymin"])
    union = area_a + area_b - inter
    return inter / union if union > 0 else 0


@app.post("/detect")
async def detect(request: Request):
    import traceback
    try:
        body = await request.body()
        if len(body) < 100:
            return JSONResponse(content={"error": f"Image too small: {len(body)} bytes"}, status_code=400)
        try:
            image = Image.open(io.BytesIO(body)).convert("RGB")
        except Exception as e:
            return JSONResponse(content={"error": f"Invalid image: {e}"}, status_code=400)
        orig_w, orig_h = image.size

        tensor, scale, dx, dy, _, _ = preprocess(image)
        output = session.run([output_name], {input_name: tensor})[0]

        results = postprocess(output, scale, dx, dy, orig_w, orig_h)
        return JSONResponse(content=results)
    except Exception as e:
        tb = traceback.format_exc()
        return JSONResponse(content={"error": str(e), "trace": tb}, status_code=500)


@app.get("/health")
async def health():
    return {"status": "ok"}
