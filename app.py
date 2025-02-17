from flask import Flask, request, jsonify
import joblib
import numpy as np
import tensorflow as tf
import os
from werkzeug.utils import secure_filename
from PIL import Image
import cv2

# Load the trained model
model = joblib.load("DyscalD.pkl")
dysgraphia_model = tf.keras.models.load_model("dysgraphia_cnn_model.h5")


# Initialize Flask app
app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)


# Function to preprocess image for CNN
def preprocess_image(image_path):
    img = Image.open(image_path).convert('RGB')
    img = img.resize((128, 128))  # Resize to match CNN input
    img = np.array(img) / 255.0  # Normalize
    img = np.expand_dims(img, axis=0)  # Add batch dimension
    return img

# Function to extract handwriting features using OCR
def extract_features(image_path):
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    _, binary = cv2.threshold(gray, 128, 255, cv2.THRESH_BINARY_INV)
    
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    stroke_widths = [cv2.contourArea(cnt) / cv2.arcLength(cnt, True) for cnt in contours if cv2.arcLength(cnt, True) > 0]
    avg_stroke_width = np.mean(stroke_widths) if stroke_widths else 0

    heights, widths = zip(*[cv2.boundingRect(cnt)[2:4] for cnt in contours]) if contours else ([], [])
    avg_letter_height = np.mean(heights) if heights else 0
    avg_letter_width = np.mean(widths) if widths else 0

    baseline_y = [cv2.boundingRect(cnt)[1] + cv2.boundingRect(cnt)[3] for cnt in contours]
    baseline_std = np.std(baseline_y) if baseline_y else 0

    spacing = [cv2.boundingRect(contours[i])[0] - (cv2.boundingRect(contours[i-1])[0] + cv2.boundingRect(contours[i-1])[2]) for i in range(1, len(contours))] if len(contours) > 1 else []
    avg_spacing = np.mean(spacing) if spacing else 0

    return {
        'stroke_width': avg_stroke_width,
        'letter_height': avg_letter_height,
        'letter_width': avg_letter_width,
        'baseline_std': baseline_std,
        'spacing': avg_spacing
    }

# Function to classify handwriting based on OCR features
def classify_ocr(features):
    dysgraphia_score = sum(1 for key, value in features.items() if 1.7 <= value <= 4.5)  # Based on dysgraphia feature ranges
    return "Dysgraphia" if dysgraphia_score > 2 else "Non-Dysgraphia"

CLASS_LABELS = ['Non-Dysgraphia', 'Dysgraphia']



@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        print(f"Received data: {data}")  # Log received data
        features = np.array(data['features']).reshape(1, -1)
        prediction = model.predict(features)[0]
        return jsonify({'prediction': int(prediction)})
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 400


@app.route('/analyze-handwriting', methods=['POST'])
def analyze_handwriting():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files['image']
    filename = secure_filename(file.filename)
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(file_path)

    try:
        # Step 1: Apply OCR-based feature extraction
        ocr_features = extract_features(file_path)
        ocr_result = classify_ocr(ocr_features)

        # Step 2: Apply CNN for image classification
        processed_img = preprocess_image(file_path)
        prediction = dysgraphia_model.predict(processed_img)[0][0]
        cnn_result = "Dysgraphia" if prediction > 0.7 else "Non-Dysgraphia"

        # Step 3: Combine results
        final_result = "Dysgraphia" if ocr_result == "Dysgraphia" or cnn_result == "Dysgraphia" else "Non-Dysgraphia"
        
        response = {
            "OCR Result": ocr_result,
            "CNN Result": cnn_result,
            "Final Result": final_result,
            "Confidence": float(prediction)
        }
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        os.remove(file_path)  # Clean up image file

    return jsonify(response)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

