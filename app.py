from flask import Flask, request, jsonify
import joblib
import numpy as np

# Load the trained model
model = joblib.load("DyscalD.pkl")

# Initialize Flask app
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    # Get JSON input
    data = request.json
    
    # Parse input features
    features = np.array(data['features']).reshape(1, -1)  # Ensure it's 2D for the model

    # Make prediction
    prediction = model.predict(features)[0]
    
    return jsonify({'prediction': int(prediction)})

if __name__ == '__main__':
    app.run(debug=True)
