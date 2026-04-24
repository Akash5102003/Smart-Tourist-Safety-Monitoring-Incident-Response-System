from sklearn.ensemble import IsolationForest
import numpy as np

# Train simple anomaly detection model
def train_model():
    # Normal distances (in km)
    normal_data = np.array([
        [0.5], [0.8], [1.0], [1.2], [1.5], [1.8]
    ])

    model = IsolationForest(contamination=0.2)
    model.fit(normal_data)
    return model

model = train_model()

# Predict anomaly
def detect_anomaly(distance):
    prediction = model.predict([[distance]])
    return prediction[0]  # -1 = anomaly, 1 = normal
