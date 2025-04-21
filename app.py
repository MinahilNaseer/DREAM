from flask import Flask, request, jsonify
import joblib
import numpy as np
import tensorflow as tf
import os
from werkzeug.utils import secure_filename
from PIL import Image
import cv2
from tensorflow.keras.preprocessing.image import img_to_array
from PIL import Image, ExifTags
from google.cloud import firestore
import google.generativeai as genai

# Configure the SDK with your hardcoded API key
genai.configure(api_key="AIzaSyB6Mm0NiURGi5atvpmiPucwCKaRHRIF22A")

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "C:\\Users\\GTS\\Downloads\\service-account-key.json"
db = firestore.Client()

model = joblib.load("DyscalD.pkl")
dysgraphia_model = tf.keras.models.load_model("dysgraphia_cnn_model.h5")



app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)


def resize_image(image, size=(128, 128)):
    return cv2.resize(image, size)

def deskew_image(image):
    coords = cv2.findNonZero(image)
    angle = cv2.minAreaRect(coords)[-1]
    if angle < -45:
        angle = -(90 + angle)
    else:
        angle = -angle
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    return cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)

def fix_orientation(image_path):
    image = Image.open(image_path)
    try:
        for orientation in ExifTags.TAGS.keys():
            if ExifTags.TAGS[orientation] == 'Orientation':
                break
        exif = dict(image._getexif().items())

        if orientation in exif:
            if exif[orientation] == 3:
                image = image.rotate(180, expand=True)
            elif exif[orientation] == 6:
                image = image.rotate(270, expand=True)
            elif exif[orientation] == 8:
                image = image.rotate(90, expand=True)
    except (AttributeError, KeyError, IndexError):
        
        pass
    return image

def remove_noise(image):
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1,1))
    return cv2.morphologyEx(image, cv2.MORPH_CLOSE, kernel)

def apply_threshold(image):
    return cv2.adaptiveThreshold(image, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)

def convert_to_grayscale(image_path):
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return gray

def preprocess_image(image_path):
    
    image = cv2.imread(image_path, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("Error: Unable to load image, file might be corrupted or unreadable.")

    
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    
    edges = cv2.Canny(blurred, 30, 150)

    
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        
        x, y, w, h = cv2.boundingRect(max(contours, key=cv2.contourArea))

        
        padding = 10
        x = max(x - padding, 0)
        y = max(y - padding, 0)
        w = min(w + (2 * padding), image.shape[1] - x)
        h = min(h + (2 * padding), image.shape[0] - y)

        
        cropped_image = image[y:y+h, x:x+w]

        
        cropped_image = cv2.resize(cropped_image, (128, 128))

        
        cv2.imwrite("cropped_image.jpg", cropped_image)
        print("Saved Cropped Image: cropped_image.jpg")

    else:
        print("No handwriting detected! Using full image.")
        cropped_image = cv2.resize(image, (128, 128))  

    
    cropped_image = cropped_image / 255.0  

    
    img_array = img_to_array(cropped_image)

    
    img_array = np.expand_dims(img_array, axis=0)

    return img_array




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

    
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        print(f"Received data: {data}")  
        uid = data.get("uid")
        if not uid:
            return jsonify({"error": "UID is missing from the request"}), 400
        features = np.array(data['features']).reshape(1, -1)
        prediction = model.predict(features)[0]
      
        store_prediction_in_firestore(uid, features.tolist(), int(prediction))
        return jsonify({
            'prediction': int(prediction),
        })

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 400
    
def store_prediction_in_firestore(uid, features, prediction):
    try:
       
        features_dict = {f"feature_{i}": feature for i, feature in enumerate(features)}
        user_ref = db.collection('users').document(uid)
        predictions_ref = user_ref.collection('predictions')
        predictions_ref.add({
            **features_dict,
            'prediction': prediction,
            'timestamp': firestore.SERVER_TIMESTAMP
        })

        print(f"Prediction stored for UID: {uid} under 'predictions' subcollection")
        all_predictions = predictions_ref.stream()
        prediction_count = sum(1 for _ in all_predictions)

        print(f"Total predictions so far: {prediction_count}")

        # If 5 predictions, trigger summary report
        if prediction_count == 5:
            generate_and_store_summary_report(uid)

    except Exception as e:
        print(f"Error storing data in Firestore: {e}")

def generate_and_store_summary_report(uid):
    try:
        predictions_ref = db.collection('users').document(uid).collection('predictions')
        predictions = predictions_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).limit(5).stream()
        prediction_values = [doc.to_dict().get('prediction') for doc in predictions]

        if len(prediction_values) < 5:
            print("Not enough predictions to generate a report.")
            return

        prompt = f"""
        Your child has completed 5 dyscalculia screening tests.

        The prediction outcomes were: {prediction_values}

        Based on these results, write a short, professional, and encouraging report for the parents.
        Do not include any closing statements like "Please do not hesitate to contact us" or organization names.
        Just conclude with whether the child may show signs of dyscalculia (if 3 or more results are 1) or not (if 3 or more are 0), and suggest any next steps if needed. and suggest any next steps if needed.
        """

        model = genai.GenerativeModel("gemini-2.0-flash")
        response = model.generate_content(prompt)
        summary = response.text
        db.collection('users').document(uid).update({
            'dyscalculia_report': summary,
            'report_generated_at': firestore.SERVER_TIMESTAMP
        })

        print(f"✅ Gemini summary report generated and stored for UID: {uid}")

    except Exception as e:
        print(f"Error generating summary report: {e}")
       
@app.route('/analyze-handwriting', methods=['POST'])
def analyze_handwriting():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files['image']
    filename = secure_filename(file.filename)
    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(file_path)

    try:
        processed_img = preprocess_image(file_path)
        print("Processed Image Shape:", processed_img.shape)  

        prediction = dysgraphia_model.predict(processed_img)[0][0]  

        cnn_result = "Dysgraphia" if prediction > 0.7 else "Non-Dysgraphia"
        final_result = "Dysgraphia" if cnn_result == "Dysgraphia" else "Non-Dysgraphia"

        response = {
            "CNN Result": cnn_result,
            "Final Result": final_result,
            "Confidence": float(prediction)
        }
    except Exception as e:
        return jsonify({"error": f"Processing error: {str(e)}"}), 500
    finally:
        os.remove(file_path)  

    return jsonify(response)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)