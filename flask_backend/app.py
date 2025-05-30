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
from dotenv import load_dotenv
import uuid  # For generating unique filenames
import psutil  # For memory monitoring in health check
import logging  # For proper error logging
load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

import json
creds_json = os.getenv("GOOGLE_CREDENTIALS_JSON")
with open("service_account_key.json", "w") as f:
    f.write(creds_json)
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "service_account_key.json"


db = firestore.Client()

import os
from pathlib import Path

current_dir = Path(__file__).parent


model_path = current_dir / "DyscalD.pkl"  
dysgraphia_path = current_dir / "dysgraphia_cnn_model.h5"

if not os.path.exists(model_path):
    raise FileNotFoundError(f"Model file not found at {model_path}")
if not os.path.exists(dysgraphia_path):
    raise FileNotFoundError(f"Dysgraphia model not found at {dysgraphia_path}")

model = joblib.load(model_path)
dysgraphia_model = tf.keras.models.load_model(dysgraphia_path, compile=False)


print("Model input shape:", dysgraphia_model.input_shape)

print("Current directory:", os.getcwd())
print("Files in current directory:", os.listdir())


app = Flask(__name__)
app.logger.setLevel(logging.INFO)

UPLOAD_FOLDER = '/tmp/uploads'  # Use tmp directory which is faster
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 2 * 1024 * 1024  # Limit uploads to 2MB

# Create upload folder if it doesn't exist
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
    try:
        # Read image in color (3 channels)
        image = cv2.imread(image_path, cv2.IMREAD_COLOR)
        if image is None:
            raise ValueError("Unable to load image")
        
        # Convert BGR to RGB (OpenCV loads as BGR by default)
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        # Simple resize and normalization
        resized = cv2.resize(image, (128, 128))
        normalized = resized / 255.0
        
        # Expand dimensions for model input
        img_array = np.expand_dims(normalized, axis=0)  # Add batch dimension
        
        return img_array
    except Exception as e:
        print(f"Error in preprocessing: {e}")
        raise




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

@app.route('/')
def home():
    return "DREAM Flask backend is running!"

@app.route('/health')
def health_check():
    return jsonify({
        "status": "healthy",
        "model_loaded": dysgraphia_model is not None,
        "memory": psutil.virtual_memory().percent
    })
   
@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.json
        print(f"Received data: {data}")
        
        uid = data.get("uid")
        child_id = data.get("childId")
        features = data.get("features")

        if not uid or not child_id or not features:
            return jsonify({"error": "UID, childId or features are missing from the request"}), 400

        features = np.array(features).reshape(1, -1)
        prediction = model.predict(features)[0]

        
        store_prediction_in_firestore(uid, child_id, features.tolist(), int(prediction))

        return jsonify({'prediction': int(prediction)})

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'error': str(e)}), 400


def store_prediction_in_firestore(uid, child_id, features, prediction):
    try:
        features_dict = {f"feature_{i}": feature for i, feature in enumerate(features)}
        child_ref = db.collection('users').document(uid).collection('children').document(child_id)
        predictions_ref = child_ref.collection('predictions')

        predictions_ref.add({
            **features_dict,
            'prediction': prediction,
            'timestamp': firestore.SERVER_TIMESTAMP,
            'usedInReport': False
        })

        print(f"Prediction stored for UID: {uid}, Child ID: {child_id}")

        unused_predictions_query = predictions_ref.where('usedInReport', '==', False)
        unused_predictions = list(unused_predictions_query.stream())

        print(f"Unused predictions for child {child_id}: {len(unused_predictions)}")

        if len(unused_predictions) >= 5:
            generate_and_store_summary_report(uid, child_id, unused_predictions[:5])

    except Exception as e:
        print(f"Error storing data in Firestore: {e}")



def generate_and_store_summary_report(uid, child_id, prediction_docs):
    try:
        prediction_values = [doc.to_dict().get('prediction') for doc in prediction_docs]

        child_doc = db.collection('users').document(uid).collection('children').document(child_id).get()
        if not child_doc.exists:
            print("Child document not found.")
            return
        child_data = child_doc.to_dict()
        name = child_data.get("name", "The child")

        prompt = f"""
Generate a professional and parent-friendly summary report for dyscalculia screening following this format:

📌 Child’s Name: {name}
📊 Test Overview:
- Total Screenings Taken: 5
- Prediction Outcomes: {prediction_values}

🧠 Interpretation:
- Analyze the predictions. If 2 or more are 1, state that the child is likely to show signs of dyscalculia.
- If 3 or more are 0, state that the child is less likely to show signs.
- Provide a warm, encouraging interpretation that avoids harsh labels.

📌 Suggested Next Steps:
- Offer 2–3 supportive next steps for parents.
- Avoid clinical language and keep tone hopeful and friendly.

Avoid adding closing phrases like “please contact us” or mentioning any organizations.
Return the output exactly in the format above.
"""
        model = genai.GenerativeModel("gemini-2.0-flash")
        response = model.generate_content(prompt)
        summary = response.text

        report_ref = db.collection('users').document(uid).collection('children').document(child_id).collection('dyscalculia_reports')
        report_ref.add({
            'report': summary,
            'predictions': prediction_values,
            'timestamp': firestore.SERVER_TIMESTAMP
        })

        print(f"Report stored for child {child_id}.")

        for doc in prediction_docs:
            doc.reference.update({'usedInReport': True})

    except Exception as e:
        print(f"Error generating summary report: {e}")


@app.route('/analyze-handwriting', methods=['POST'])
def analyze_handwriting():
    try:
        # Validate request
        if 'image' not in request.files:
            app.logger.error("No image uploaded")
            return jsonify({"error": "No image uploaded"}), 400

        # Get form data with defaults
        uid = request.form.get('uid', '')
        child_id = request.form.get('childId', '')
        word = request.form.get('word', 'unknown')

        if not uid or not child_id:
            app.logger.error("Missing UID or childId")
            return jsonify({"error": "Missing required fields"}), 400

        # Process file
        file = request.files['image']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400
            
        # Create secure filename with UUID
        ext = os.path.splitext(file.filename)[1]
        filename = f"{uuid.uuid4().hex}{ext}"
        temp_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        
        try:
            file.save(temp_path)
            
            # Process image
            processed_img = preprocess_image(temp_path)
            if processed_img.shape[-1] != 3:
                app.logger.error(f"Invalid input shape: {processed_img.shape}")
                return jsonify({"error": "Invalid image format"}), 400
            
            # Make prediction - limit to 10 seconds
            try:
                prediction = dysgraphia_model.predict(processed_img, verbose=0)[0][0]
                result = "Dysgraphia" if prediction > 0.7 else "Non-Dysgraphia"
            except Exception as predict_error:
                app.logger.error(f"Prediction failed: {str(predict_error)}")
                return jsonify({"error": "Prediction failed"}), 500
            
            # Store results
            storage_success = store_handwriting_prediction_in_firestore(
                uid, child_id, float(prediction), result, word
            )
            
            if not storage_success:
                return jsonify({
                    "result": result,
                    "confidence": float(prediction),
                    "word": word,
                    "warning": "Results could not be saved to database"
                })
            
            return jsonify({
                "result": result,
                "confidence": float(prediction),
                "word": word
            })
            
        except Exception as processing_error:
            app.logger.error(f"Image processing failed: {str(processing_error)}")
            return jsonify({"error": "Image processing failed"}), 500
            
        finally:
            # Clean up temp file
            if os.path.exists(temp_path):
                try:
                    os.remove(temp_path)
                except:
                    pass
                
    except Exception as e:
        app.logger.error(f"Error in analyze_handwriting: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500


def store_handwriting_prediction_in_firestore(uid, child_id, confidence_score, final_result, word=None):
    try:
        print(f"Attempting to store for {uid}/{child_id}")
        print(f"Data: {confidence_score}, {final_result}, {word}")


        if not db:
            raise Exception("Firestore client not initialized")

        doc_ref = db.collection('users').document(uid)\
                  .collection('children').document(child_id)\
                  .collection('handwriting_predictions').document()

        data = {
            'confidence': float(confidence_score),
            'result': str(final_result),
            'timestamp': firestore.SERVER_TIMESTAMP,
            'usedInReport': False,
            'word': word or 'unknown'
        }

        doc_ref.set(data)
        print(f"Successfully stored prediction {doc_ref.id}")


        unused_query = db.collection('users').document(uid)\
                      .collection('children').document(child_id)\
                      .collection('handwriting_predictions')\
                      .where('usedInReport', '==', False)

        unused_predictions = list(unused_query.stream())
        print(f"Unused predictions: {len(unused_predictions)}")

        if len(unused_predictions) >= 5:
            print("Generating summary report...")
            generate_and_store_handwriting_summary(uid, child_id,unused_predictions)

        return True

    except Exception as e:
        print(f"Storage failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False


def generate_and_store_handwriting_summary(uid, child_id, prediction_docs):
    try:
        prediction_results = [doc.to_dict().get('result') for doc in prediction_docs]

        child_doc = db.collection('users').document(uid).collection('children').document(child_id).get()
        if not child_doc.exists:
            print("Child document not found.")
            return

        child_data = child_doc.to_dict()
        name = child_data.get("name", "The child")

        prompt = f"""
You are acting as a child screening assistant. Generate a warm, professional, and parent-friendly summary report for a screening session based on the following results.

✅Instructions:
- Use **Markdown formatting** with **bold titles**, emojis, and bullets.
- Clearly emphasize the **likelihood of risk** using boldness and emojis.
- Keep the language **non-clinical**, supportive, and encouraging.
- Do **not** include any external organization names, diagnosis claims, or contact suggestions.

📌 Child’s Name: {name}

📊 Test Overview:
- Total Screenings Taken: 5
- Prediction Results: {prediction_results}

🧠 Interpretation:
Based on the results:
- If 2 or more predictions are **"Dyslexia/Dysgraphia/Dyscalculia"**, state:
  🔴 The child may be showing some signs of [condition]. Emphasize that this is not a diagnosis but a helpful observation.
- If 3 or more predictions are **"Non-Dyslexia/Non-Dysgraphia/0", state:
  🟢 The child is less likely to show signs of [condition].
- Always remind that screenings are **just one piece of the puzzle** in understanding a child’s learning style.

📌 Suggested Next Steps:
Here are some supportive actions you can take:
- ✨ Suggest 2–3 home-friendly, practical ideas (e.g., motor skills games, interactive math tasks, storytelling).
- 🎯 Ensure suggestions feel empowering and easy to follow for parents.
- Do not mention clinics, therapy, or assessments directly.

🎨 Style Guide:
- Use **bold** for headings and important points.
- Add **relevant emojis** to improve tone and engagement.
- Make it feel **like a summary card** that’s quick and reassuring to read.
- End on a warm, optimistic note — but no formal conclusion.

⚠️ Return **only the formatted final report**. Do not include explanations or extra commentary.
"""



        model = genai.GenerativeModel("gemini-2.0-flash")
        response = model.generate_content(prompt)
        summary = response.text

        db.collection('users').document(uid).collection('children').document(child_id).collection('dysgraphia_reports').add({
            'report': summary,
            'predictions': prediction_results,
            'timestamp': firestore.SERVER_TIMESTAMP
        })

        print(f"Handwriting summary report stored for UID: {uid}, Child ID: {child_id}")

        for doc in prediction_docs:
            doc.reference.update({'usedInReport': True})

    except Exception as e:
        print(f" Error generating dysgraphia summary report: {e}")


@app.route('/generate_dyslexia_report', methods=['POST'])
def generate_dyslexia_report():
    try:
       
        data = request.get_json()

        
        uid = data.get('uid')
        child_id = data.get('child_id')
        scores = data.get('scores')

        if not uid or not child_id or not scores:
            return jsonify({"error": "Missing required data"}), 400

        
        child_ref = db.collection('users').document(uid).collection('children').document(child_id)
        child_doc = child_ref.get()
        child_name = child_doc.get('name')  

        if not child_name:
            return jsonify({"error": "Child's name not found"}), 400

        
        total_score = scores['total_score']
        percentage = scores['percentage']
        risk = scores['risk']

        
        prompt = f"""
Here's a dyslexia screening report for {child_name}, designed to be professional, parent-friendly, and encouraging.

📌 Child’s Name: {child_name}

📊 Test Overview:
- Fishing Level: {scores['fishingLevelScore']} (This activity assesses the child's visual processing and letter recognition through a fun and engaging fishing game.)
- Audio Level: {scores['forestLevelScore']} (This activity evaluates the child's ability to recognize and differentiate various sounds, helping assess auditory discrimination skills.)
- Color and Letter Level: {scores['colorLetterLevelScore']} (This task focuses on identifying letters associated with specific colors, supporting knowledge of letter-sound correspondence.)
- Reading Level: {scores['pronunciationLevelScore']} (This activity assesses the child’s early reading and phonetic pronunciation abilities by encouraging verbal repetition.)
- Total Score: {total_score} / 9 ({percentage}%)

🧠 Interpretation:
Based on the results, the diagnosis is: {risk}.
If the risk is high or moderate, parents are encouraged to consider further evaluation to better understand the child’s learning needs and support strategies.

📌 Suggested Next Steps:
- Encourage regular activities that strengthen reading, listening, and phonics skills in a supportive environment.
- Provide opportunities for interactive learning such as reading aloud together, using phonics games, or exploring sound-matching tasks.
- If needed, consult with an educational specialist to gain deeper insight into the child’s specific needs and development path.

Please generate a warm, encouraging, and supportive report in paragraph form based on the above structure. Avoid any harsh, overly clinical, or technical language, and ensure the tone is positive and reassuring.
"""
        model = genai.GenerativeModel("gemini-2.0-flash")
        response = model.generate_content(prompt)

        if response:
            report = response.text  

            return jsonify({"report": report}), 200
        else:
            return jsonify({"error": "Failed to generate a report from Gemini."}), 500

    except Exception as e:
        print(f"Failed to generate dyslexia report: {str(e)}")
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


port = int(os.environ.get("PORT", 10000))  # fallback to 10000 if PORT not set
app.run(host='0.0.0.0', port=port)
