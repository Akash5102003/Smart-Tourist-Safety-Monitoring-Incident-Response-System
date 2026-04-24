from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3
import math

from ml_model import detect_anomaly
from blockchain_service import register_tourist, get_tourist

app = Flask(__name__)
CORS(app)

# ---------------- DATABASE INIT ----------------

def init_db():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()

    # USERS TABLE
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
        )
    ''')

    cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT,
    password TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
''')

    # LOCATION TABLE
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    conn.commit()
    conn.close()

init_db()

# ---------------- UTIL ----------------

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)

    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) *
         math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)

    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

# ---------------- HOME ----------------

@app.route('/')
def home():
    return jsonify({"message": "Backend server is running"})

# ---------------- AUTH ----------------

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json

    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO users (username, password) VALUES (?, ?)",
        (data["username"], data["password"])
    )

    conn.commit()
    conn.close()

    return jsonify({"message": "User registered successfully"})

@app.route('/login', methods=['POST'])
def login():
    data = request.json

    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM users WHERE username=? AND password=?",
        (data["username"], data["password"])
    )

    user = cursor.fetchone()
    conn.close()

    if user:
        return jsonify({"message": "Login success"})
    else:
        return jsonify({"message": "Invalid credentials"}), 401

# ---------------- LOCATION ----------------

@app.route('/location', methods=['POST'])
def receive_location():
    data = request.json
    lat = data.get("latitude")
    lon = data.get("longitude")

    # SAVE LOCATION (PERMANENT)
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO locations (latitude, longitude) VALUES (?, ?)",
        (lat, lon)
    )

    conn.commit()
    conn.close()

    # SAFE ZONE
    safe_lat = 12.9716
    safe_lon = 77.5946
    radius_km = 2

    distance = calculate_distance(lat, lon, safe_lat, safe_lon)

    if distance <= radius_km:
        status = "SAFE ZONE"
    else:
        status = "OUTSIDE SAFE ZONE - ALERT"

    # AI
    anomaly = detect_anomaly(distance)

    if anomaly == -1:
        behavior = "ABNORMAL BEHAVIOR DETECTED"
    else:
        behavior = "NORMAL BEHAVIOR"

    return jsonify({
        "geo_fence_status": status,
        "distance_km": round(distance, 2),
        "behavior": behavior
    })

# ---------------- LOCATION HISTORY ----------------

@app.route('/locations', methods=['GET'])
def get_locations():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()

    cursor.execute("""
        SELECT latitude, longitude, timestamp 
        FROM locations 
        ORDER BY id DESC 
        LIMIT 10
    """)

    data = cursor.fetchall()
    conn.close()

    return jsonify(data)

# ---------------- PANIC ----------------

alerts_log = []

@app.route('/panic', methods=['POST'])
def panic_alert():
    data = request.json

    alerts_log.append({
        "type": "PANIC",
        "location": data.get("location", "Unknown")
    })

    return jsonify({
        "status": "Alert received",
        "location": data.get("location", "Unknown")
    })

# ---------------- BLOCKCHAIN ----------------

@app.route('/register', methods=['POST'])
def register_blockchain_tourist():
    data = request.json

    register_tourist(
        data["address"],
        data["name"],
        data["idHash"]
    )

    return jsonify({"message": "Tourist registered on blockchain"})

@app.route('/tourist/<address>', methods=['GET'])
def get_blockchain_tourist(address):
    tourist = get_tourist(address)
    return jsonify(tourist)

# ---------------- TEST ----------------

@app.route('/test')
def test():
    return "API working"

# ---------------- RUN ----------------

if __name__ == '__main__':
    app.run(debug=True)