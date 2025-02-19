from flask import Flask, request, jsonify
import joblib
import numpy as np
import tensorflow as tf
import os
from werkzeug.utils import secure_filename
from PIL import Image,ImageOps
import cv2
from dotenv import load_dotenv
import pytesseract

load_dotenv()


model = joblib.load("DyscalD.pkl")
dysgraphia_model = tf.keras.models.load_model("dysgraphia_cnn_model.h5")



app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

pytesseract.pytesseract.tesseract_cmd = r"C:/Program Files/Tesseract-OCR/tesseract.exe"

def detect_word_area(image_path):
    """ Detects the bounding box of the handwritten word using OCR & image processing. """
    img = cv2.imread(image_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Apply thresholding to create a binary image
    _, binary = cv2.threshold(gray, 128, 255, cv2.THRESH_BINARY_INV)

    # Use OCR to detect text regions
    ocr_data = pytesseract.image_to_data(binary, output_type=pytesseract.Output.DICT)
    
    word_boxes = []
    for i, word in enumerate(ocr_data['text']):
        if word.strip():  # Ensure it's a valid detected word
            x, y, w, h = ocr_data['left'][i], ocr_data['top'][i], ocr_data['width'][i], ocr_data['height'][i]
            word_boxes.append((x, y, w, h))
    
    if word_boxes:
        # Get bounding box of all detected words (merge them)
        x_min = min([box[0] for box in word_boxes])
        y_min = min([box[1] for box in word_boxes])
        x_max = max([box[0] + box[2] for box in word_boxes])
        y_max = max([box[1] + box[3] for box in word_boxes])

        # Add some padding to avoid cutting off edges
        padding_x = int((x_max - x_min) * 0.2)
        padding_y = int((y_max - y_min) * 0.2)

        x_min = max(0, x_min - padding_x)
        y_min = max(0, y_min - padding_y)
        x_max = min(img.shape[1], x_max + padding_x)
        y_max = min(img.shape[0], y_max + padding_y)

        return img[y_min:y_max, x_min:x_max]  # Cropped Image
    return None  # No word detected

def preprocess_image(image_path):
    """ Uses OCR to localize word, then processes the extracted word for CNN classification. """
    word_img = detect_word_area(image_path)

    if word_img is None:
        # If OCR fails, use original image
        word_img = cv2.imread(image_path)

    # Convert image to PIL for resizing
    img = Image.fromarray(cv2.cvtColor(word_img, cv2.COLOR_BGR2RGB))

    # Fix orientation issues
    img = ImageOps.exif_transpose(img)

    # Resize to 128x128 for CNN input
    img = img.resize((128, 128))
    img = np.array(img) / 255.0
    img = np.expand_dims(img, axis=0)

    return img



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

dysgraphia_ranges = {
    'stroke_width': (1.7, 2.6),          
    'letter_height': (1.7, 4.5),         
    'letter_width': (1.2, 2.5),          
    'baseline_std': (1.7, 4.5),          
    'spacing': (1.0, 3.0)                
}

no_dysgraphia_ranges = {
    'stroke_width': (1.3, 2.1),          
    'letter_height': (1.9, 3.1),         
    'letter_width': (1.3, 2.1),          
    'baseline_std': (0.5, 1.5),          
    'spacing': (2.0, 4.0)                
}


def classify_ocr(features):
    dysgraphia_score = 0
    no_dysgraphia_score = 0
    
    for key, value in features.items():
        if dysgraphia_ranges[key][0] <= value <= dysgraphia_ranges[key][1]:
            dysgraphia_score += 1
        if no_dysgraphia_ranges[key][0] <= value <= no_dysgraphia_ranges[key][1]:
            no_dysgraphia_score += 1
    
    return "Dysgraphia" if dysgraphia_score > no_dysgraphia_score else "Non-Dysgraphia"

    


@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        print(f"Received data: {data}")  
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
        
        #features = extract_features(file_path)
        #ocr_result = classify_ocr(features)

        
        processed_img = preprocess_image(file_path)
        prediction = dysgraphia_model.predict(processed_img)[0][0]
        cnn_result = "Dysgraphia" if prediction > 0.7 else "Non-Dysgraphia"

        
        final_result = "Dysgraphia" if cnn_result == "Dysgraphia" else "Non-Dysgraphia"
        
        response = {
            #"OCR Result": ocr_result,
            "CNN Result": cnn_result,
            "Final Result": final_result,
            "Confidence": float(prediction)
        }
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        os.remove(file_path)  

    return jsonify(response)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

