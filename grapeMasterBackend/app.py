import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
import torch

app = Flask(__name__)
# Enable CORS for all routes - allows Flutter app to make requests
CORS(app)

# ==============================
# Load Model (Auto-detect type)
# ==============================
MODEL_PATH = r"best.pt"

print(f"Loading model from: {MODEL_PATH}")
if MODEL_PATH.endswith(".engine"):
    print("Detected TensorRT Engine model ✅")
else:
    print("Detected PyTorch model ✅")

# Load YOLO model (works for both .pt and .engine)
model = YOLO(MODEL_PATH)

# ==============================
# Prediction Endpoint
# ==============================
@app.route("/predict", methods=["POST", "OPTIONS"])
def predict():
    # Handle preflight OPTIONS request for CORS
    if request.method == "OPTIONS":
        return jsonify({"status": "ok"}), 200
    
    print(f"\n{'='*60}")
    print(f"📥 Received {request.method} request to /predict")
    print(f"   Content-Type: {request.content_type}")
    print(f"   Files in request: {list(request.files.keys())}")
    print(f"   Form data: {list(request.form.keys())}")
    print(f"{'='*60}\n")
    
    if "file" not in request.files:
        print("❌ Error: No file in request")
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["file"]
    print(f"📎 File received: {file.filename}")
    
    if file.filename == "":
        print("❌ Error: Empty filename")
        return jsonify({"error": "Empty filename"}), 400

    try:
        # Save temporary uploaded file
        image_path = os.path.join("uploads", file.filename)
        os.makedirs("uploads", exist_ok=True)
        file.save(image_path)
        print(f"💾 Image saved to: {image_path}")

        # TensorRT → must use batch=1
        if MODEL_PATH.endswith(".engine"):
            print("🚀 Running TensorRT inference...")
            results = list(model(source=image_path, batch=1))
        else:
            print("🚀 Running PyTorch inference...")
            results = list(model(source=image_path))

        # Extract predicted class
        pred_label = results[0].names[int(results[0].probs.top1)]
        confidence = float(results[0].probs.top1conf)
        
        print(f"✅ Prediction: {pred_label} (confidence: {confidence:.4f})")

        # Cleanup
        os.remove(image_path)
        print(f"🗑️  Temporary file cleaned up\n")

        return jsonify({
            "prediction": pred_label,
            "confidence": round(confidence, 4)
        })

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


# ==============================
# Run Flask app
# ==============================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000, debug=True)
