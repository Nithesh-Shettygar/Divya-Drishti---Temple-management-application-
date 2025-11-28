# app.py (updated - adds stable user_ref and booking_ref generation)
from flask import Flask, request, jsonify, abort
import mysql.connector
from mysql.connector import Error
from werkzeug.security import generate_password_hash, check_password_hash
from flask_cors import CORS
import random
import datetime
from datetime import timedelta, date
import uuid
import json
import os
import time

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# ---------- DATABASE CONNECTION & SETUP ----------
def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=os.environ.get("DB_HOST", "localhost"),
            user=os.environ.get("DB_USER", "root"),
            password=os.environ.get("DB_PASS", ""),
            database=os.environ.get("DB_NAME", "divya_drishti_db"),
            autocommit=False
        )
        return conn
    except Error as e:
        print(f"❌ Database connection failed: {e}")
        return None

def create_tables():
    """Create necessary tables if they don't exist. Adds user_ref and booking_ref columns."""
    conn = get_db_connection()
    if not conn:
        print("❌ Cannot create tables - no database connection")
        return False

    try:
        cursor = conn.cursor()

        # Users with user_ref
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_ref VARCHAR(50) UNIQUE NOT NULL,
                phone VARCHAR(15) UNIQUE NOT NULL,
                name VARCHAR(255) NOT NULL,
                dob DATE NOT NULL,
                gender ENUM('Male', 'Female', 'Other') NOT NULL,
                address TEXT NOT NULL,
                password VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ''')

        # OTPs
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS otps (
                id INT AUTO_INCREMENT PRIMARY KEY,
                phone VARCHAR(15) NOT NULL,
                otp_code VARCHAR(6) NOT NULL,
                expires_at TIMESTAMP NOT NULL,
                used BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        # Bookings with booking_ref
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS bookings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                booking_ref VARCHAR(50) UNIQUE NOT NULL,
                title VARCHAR(255) NOT NULL,
                booking_date DATE NOT NULL,
                time_slot VARCHAR(100) NOT NULL,
                persons INT NOT NULL,
                amount INT NOT NULL DEFAULT 0,
                paid BOOLEAN DEFAULT FALSE,
                payment_ref VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')

        # Persons
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS persons (
                id INT AUTO_INCREMENT PRIMARY KEY,
                booking_id INT NOT NULL,
                name VARCHAR(255),
                phone VARCHAR(50),
                gender VARCHAR(20),
                age VARCHAR(10),
                is_elder_disabled BOOLEAN DEFAULT FALSE,
                elder_age VARCHAR(10),
                wheelchair_required BOOLEAN,
                FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
            )
        ''')

        # Notifications
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                type VARCHAR(50) DEFAULT 'general',
                booking_id INT NULL,
                is_read BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
            )
        ''')

        # Index creation (wrap with try to avoid errors if index exists)
        try: cursor.execute('CREATE INDEX idx_users_phone ON users(phone)')
        except: pass
        try:
            cursor.execute('CREATE INDEX idx_otps_phone ON otps(phone)')
            cursor.execute('CREATE INDEX idx_otps_expires ON otps(expires_at)')
            cursor.execute('CREATE INDEX idx_otps_used ON otps(used)')
        except: pass
        try:
            cursor.execute('CREATE INDEX idx_bookings_date ON bookings(booking_date)')
            cursor.execute('CREATE INDEX idx_bookings_paid ON bookings(paid)')
        except: pass
        try:
            cursor.execute('CREATE INDEX idx_notifications_booking ON notifications(booking_id)')
            cursor.execute('CREATE INDEX idx_notifications_isread ON notifications(is_read)')
        except: pass

        conn.commit()
        cursor.close()
        conn.close()
        print("✅ Database tables created/verified successfully (with user_ref & booking_ref).")
        return True

    except Error as e:
        print(f"❌ Error creating tables: {e}")
        try:
            conn.rollback()
        except:
            pass
        return False

# ---------- HELPERS ----------
def to_serializable(value):
    """Convert MySQL return types to JSON serializable"""
    if isinstance(value, (datetime.date, datetime.datetime)):
        return value.isoformat()
    if isinstance(value, (bytes, bytearray)):
        return value.decode('utf-8')
    return value

def serialize_row(row: dict):
    """Return a copy of row with datetimes converted to strings"""
    out = {}
    for k, v in row.items():
        out[k] = to_serializable(v)
    return out

def generate_short_ref(prefix: str, length: int = 8):
    """Generate a short hex-based ref like PREFIX-1a2b3c4d"""
    return f"{prefix}-{uuid.uuid4().hex[:length]}"

def ensure_unique_user_ref(conn):
    """Generate a user_ref that doesn't exist yet (small loop, extremely unlikely to loop many times)."""
    tries = 0
    while True:
        tries += 1
        ref = generate_short_ref("USR", 8)
        cur = conn.cursor()
        cur.execute("SELECT id FROM users WHERE user_ref=%s", (ref,))
        if not cur.fetchone():
            cur.close()
            return ref
        cur.close()
        if tries > 5:
            time.sleep(0.05)

def ensure_unique_booking_ref(conn):
    tries = 0
    while True:
        tries += 1
        ref = generate_short_ref("BK", 10)
        cur = conn.cursor()
        cur.execute("SELECT id FROM bookings WHERE booking_ref=%s", (ref,))
        if not cur.fetchone():
            cur.close()
            return ref
        cur.close()
        if tries > 5:
            time.sleep(0.05)

def generate_otp():
    return str(random.randint(1000, 9999))

def save_otp(phone, otp_code):
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor()
        expires_at = datetime.datetime.now() + timedelta(minutes=10)
        cursor.execute('UPDATE otps SET used = TRUE WHERE phone = %s', (phone,))
        cursor.execute('INSERT INTO otps (phone, otp_code, expires_at) VALUES (%s, %s, %s)',
                       (phone, otp_code, expires_at))
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Error as e:
        print(f"❌ Error saving OTP: {e}")
        try:
            conn.rollback()
        except:
            pass
        return False

def verify_otp_in_db(phone, otp_code):
    conn = get_db_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute('''
            SELECT * FROM otps 
            WHERE phone = %s AND otp_code = %s AND used = FALSE AND expires_at > NOW()
            ORDER BY created_at DESC LIMIT 1
        ''', (phone, otp_code))
        otp_data = cursor.fetchone()
        if otp_data:
            cursor.execute('UPDATE otps SET used = TRUE WHERE id = %s', (otp_data['id'],))
            conn.commit()
            cursor.close()
            conn.close()
            return True
        cursor.close()
        conn.close()
        return False
    except Error as e:
        print(f"❌ Error verifying OTP in DB: {e}")
        try:
            conn.rollback()
        except:
            pass
        return False

def insert_notification(title, message, _type='general', booking_id=None):
    try:
        conn = get_db_connection()
        if not conn:
            return False
        cursor = conn.cursor()
        cursor.execute('INSERT INTO notifications (title, message, type, booking_id) VALUES (%s,%s,%s,%s)',
                       (title, message, _type, booking_id))
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print("❌ insert_notification error:", e)
        try:
            conn.rollback()
        except:
            pass
        return False

# ---------- SLOT MOCK ----------
def generate_slot_availability(start_date: date, days: int = 60):
    slots = []
    today = date.today()
    for i in range(days):
        d = start_date + timedelta(days=i)
        is_opened = d >= today
        is_available = is_opened and (d.weekday() != 6) and (d.day % 2 == 0)
        total_slots = 100
        available_slots = (d.day % 4) * 25 if is_available else 0
        slots.append({
            "date": d.isoformat(),
            "is_opened": bool(is_opened),
            "is_available": bool(is_available),
            "available_slots": int(available_slots),
            "total_slots": int(total_slots),
        })
    return slots

# ---------- ROUTES ----------
@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "success",
        "message": "Divya Drishti Flask server is running!",
        "mode": "DEVELOPMENT - Dummy OTP",
        "database": os.environ.get("DB_NAME", "divya_drishti_db")
    })

@app.route("/send-otp", methods=["POST"])
def send_otp():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "No JSON data received"}), 400
        phone = data.get("phone")
        if not phone:
            return jsonify({"status": "error", "message": "Phone number is required"}), 400
        otp_code = generate_otp()
        saved = save_otp(phone, otp_code)
        if not saved:
            print("⚠️ Warning: OTP was not saved to DB")
        print(f"📱 DEVELOPMENT MODE - OTP for {phone}: {otp_code}")
        return jsonify({"status": "success", "message": "OTP sent successfully", "development_mode": True, "otp": otp_code}), 200
    except Exception as e:
        print(f"❌ Send OTP error: {e}")
        return jsonify({"status": "error", "message": f"Server error: {str(e)}"}), 500

@app.route("/verify-otp", methods=["POST"])
def verify_otp_route():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "No JSON data received"}), 400
        phone = data.get("phone")
        otp = data.get("otp")
        if not phone or not otp:
            return jsonify({"status": "error", "message": "Phone and OTP are required"}), 400
        if isinstance(otp, str) and len(otp) == 4 and otp.isdigit():
            if verify_otp_in_db(phone, otp):
                return jsonify({"status": "success", "message": "OTP verified successfully", "development_mode": True}), 200
            else:
                return jsonify({"status": "success", "message": "OTP verified successfully (dev)", "development_mode": True}), 200
        else:
            return jsonify({"status": "error", "message": "Invalid OTP format"}), 400
    except Exception as e:
        print(f"❌ Verify OTP error: {e}")
        return jsonify({"status": "error", "message": f"Server error: {str(e)}"}), 500

# ---------- USER / PROFILE ----------
@app.route("/register", methods=["POST"])
def register():
    conn = None
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "No JSON data received"}), 400
        phone = data.get("phone")
        name = data.get("name")
        dob = data.get("dob")
        gender = data.get("gender")
        address = data.get("address")
        password = data.get("password")

        if not all([phone, name, dob, gender, address, password]):
            return jsonify({"status": "error", "message": "All fields are required"}), 400
        if len(phone) != 10 or not phone.isdigit():
            return jsonify({"status": "error", "message": "Phone number must be 10 digits"}), 400
        if len(password) < 6:
            return jsonify({"status": "error", "message": "Password must be at least 6 characters"}), 400
        try:
            datetime.datetime.strptime(dob, "%Y-%m-%d")
        except Exception:
            return jsonify({"status": "error", "message": "DOB must be in YYYY-MM-DD format"}), 400

        conn = get_db_connection()
        if not conn:
            return jsonify({"status": "error", "message": "Database not connected"}), 500

        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE phone=%s", (phone,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"status": "error", "message": "Phone number already registered"}), 400

        # generate unique user_ref
        user_ref = ensure_unique_user_ref(conn)

        hashed_pw = generate_password_hash(password)
        cursor.execute(
            "INSERT INTO users (user_ref, phone, name, dob, gender, address, password) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (user_ref, phone, name, dob, gender, address, hashed_pw)
        )
        conn.commit()
        user_id = cursor.lastrowid
        cursor.execute("SELECT id, user_ref, phone, name, dob, gender, address, created_at FROM users WHERE id=%s", (user_id,))
        user_data = cursor.fetchone()
        cursor.close()
        conn.close()

        user_response = {
            "id": user_data["id"],
            "user_ref": user_data["user_ref"],
            "phone": user_data["phone"],
            "name": user_data["name"],
            "dob": str(user_data["dob"]),
            "gender": user_data["gender"],
            "address": user_data["address"],
            "created_at": to_serializable(user_data["created_at"])
        }
        return jsonify({"status": "success", "message": "User registered successfully", "user": user_response}), 201

    except Error as e:
        print(f"❌ Database error: {e}")
        try:
            if conn:
                conn.rollback()
        except: pass
        return jsonify({"status": "error", "message": f"Database error: {str(e)}"}), 500
    except Exception as e:
        print(f"❌ Registration error: {e}")
        try:
            if conn:
                conn.rollback()
        except: pass
        return jsonify({"status": "error", "message": f"Server error: {str(e)}"}), 500

@app.route("/login", methods=["POST"])
def login():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "No JSON data received"}), 400
        phone = data.get("phone")
        password = data.get("password")
        if not phone or not password:
            return jsonify({"status": "error", "message": "Phone and password required"}), 400

        conn = get_db_connection()
        if not conn:
            return jsonify({"status": "error", "message": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE phone=%s", (phone,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user and check_password_hash(user["password"], password):
            user_info = {
                "id": user["id"],
                "user_ref": user.get("user_ref"),
                "phone": user["phone"],
                "name": user["name"],
                "dob": str(user["dob"]),
                "gender": user["gender"],
                "address": user["address"],
                "created_at": to_serializable(user["created_at"])
            }
            return jsonify({"status": "success", "message": "Login successful", "user": user_info}), 200
        else:
            return jsonify({"status": "error", "message": "Invalid phone number or password"}), 401

    except Exception as e:
        print(f"❌ Login error: {e}")
        return jsonify({"status": "error", "message": f"Server error: {str(e)}"}), 500

@app.route("/profile/<phone>", methods=["GET"])
def get_profile(phone):
    try:
        if not phone:
            return jsonify({"status": "error", "message": "Phone number is required"}), 400
        conn = get_db_connection()
        if not conn:
            return jsonify({"status": "error", "message": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, user_ref, phone, name, dob, gender, address, created_at FROM users WHERE phone=%s", (phone,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()
        if user:
            user_info = {
                "id": user["id"],
                "user_ref": user.get("user_ref"),
                "phone": user["phone"],
                "name": user["name"],
                "dob": str(user["dob"]),
                "gender": user["gender"],
                "address": user["address"],
                "created_at": to_serializable(user["created_at"])
            }
            return jsonify({"status": "success", "user": user_info}), 200
        else:
            return jsonify({"status": "error", "message": "User not found"}), 404
    except Exception as e:
        print(f"❌ Profile error: {e}")
        return jsonify({"status": "error", "message": f"Server error: {str(e)}"}), 500

@app.route("/profile", methods=["PUT"])
def update_profile():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "No JSON data received"}), 400
        phone = data.get("phone")
        name = data.get("name")
        dob = data.get("dob")
        gender = data.get("gender")
        address = data.get("address")
        if not all([phone, name, dob, gender, address]):
            return jsonify({"status": "error", "message": "All fields are required"}), 400
        try:
            datetime.datetime.strptime(dob, "%Y-%m-%d")
        except Exception:
            return jsonify({"status": "error", "message": "DOB must be in YYYY-MM-DD format"}), 400

        conn = get_db_connection()
        if not conn:
            return jsonify({"status": "error", "message": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE phone=%s", (phone,))
        user = cursor.fetchone()
        if not user:
            cursor.close()
            conn.close()
            return jsonify({"status": "error", "message": "User not found"}), 404
        cursor.execute("UPDATE users SET name=%s, dob=%s, gender=%s, address=%s WHERE phone=%s", (name, dob, gender, address, phone))
        conn.commit()
        cursor.execute("SELECT id, user_ref, phone, name, dob, gender, address, created_at FROM users WHERE phone=%s", (phone,))
        updated_user = cursor.fetchone()
        cursor.close()
        conn.close()
        user_info = {
            "id": updated_user["id"],
            "user_ref": updated_user.get("user_ref"),
            "phone": updated_user["phone"],
            "name": updated_user["name"],
            "dob": str(updated_user["dob"]),
            "gender": updated_user["gender"],
            "address": updated_user["address"],
            "created_at": to_serializable(updated_user["created_at"])
        }
        return jsonify({"status": "success", "message": "Profile updated successfully", "user": user_info}), 200
    except Exception as e:
        print(f"❌ Update profile error: {e}")
        return jsonify({"status": "error", "message": f"Server error: {str(e)}"}), 500

@app.route("/reset-password", methods=["POST"])
def reset_password():
    try:
        data = request.get_json()
        if not data:
            return jsonify({"status": "error", "message": "No JSON data received"}), 400
        phone = data.get("phone")
        new_password = data.get("new_password")
        if not phone or not new_password:
            return jsonify({"status": "error", "message": "Phone and new password are required"}), 400
        if len(new_password) < 6:
            return jsonify({"status": "error", "message": "Password must be at least 6 characters"}), 400

        conn = get_db_connection()
        if not conn:
            return jsonify({"status": "error", "message": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users WHERE phone=%s", (phone,))
        user = cursor.fetchone()
        if not user:
            cursor.close()
            conn.close()
            return jsonify({"status": "error", "message": "User not found"}), 404
        hashed_pw = generate_password_hash(new_password)
        cursor.execute("UPDATE users SET password=%s WHERE phone=%s", (hashed_pw, phone))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"status": "success", "message": "Password reset successfully"}), 200
    except Exception as e:
        print(f"❌ Reset password error: {e}")
        return jsonify({"status": "error", "message": f"Server error: {str(e)}"}), 500

# ---------- CHECK / DEV ----------
@app.route("/check-tables", methods=["GET"])
def check_tables():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"status": "error", "message": "Database not connected"}), 500
        cursor = conn.cursor()
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        table_list = [table[0] for table in tables]
        cursor.close()
        conn.close()
        return jsonify({
            "status": "success",
            "tables": table_list,
            "users_table_exists": "users" in table_list,
            "otps_table_exists": "otps" in table_list,
            "bookings_table_exists": "bookings" in table_list,
            "persons_table_exists": "persons" in table_list,
            "notifications_table_exists": "notifications" in table_list
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": f"Error: {str(e)}"}), 500

@app.route("/dev/users", methods=["GET"])
def get_all_users():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"status": "error", "message": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, user_ref, phone, name, dob, gender, address, created_at FROM users")
        users = cursor.fetchall()
        for u in users:
            if 'created_at' in u and u['created_at']:
                u['created_at'] = to_serializable(u['created_at'])
        cursor.close()
        conn.close()
        return jsonify({"status": "success", "users": users}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": f"Error: {str(e)}"}), 500

# ---------- SLOTS, BOOKING, PAYMENT, NOTIFICATIONS, HISTORY ----------
@app.route("/slots", methods=["GET"])
def slots():
    start_str = request.args.get("start")
    days = int(request.args.get("days", 60))
    try:
        if start_str:
            start = datetime.datetime.strptime(start_str, "%Y-%m-%d").date()
        else:
            start = date.today()
    except Exception:
        return jsonify({"error": "Invalid 'start' date format. Use YYYY-MM-DD."}), 400
    days = max(1, min(days, 365))
    data = generate_slot_availability(start, days)
    return jsonify({"start": start.isoformat(), "days": days, "slots": data})

@app.route("/book", methods=["POST"])
def book():
    conn = None
    try:
        data = request.get_json(force=True)
        if not data:
            return jsonify({"error": "JSON body required"}), 400

        title = data.get("title")
        date_str = data.get("date")
        time_slot = data.get("time_slot")
        persons = int(data.get("persons", 1))
        person_details = data.get("person_details", [])
        amount = int(data.get("amount", 100 * persons))

        if not title or not date_str or not time_slot:
            return jsonify({"error": "Missing required fields: title, date, time_slot"}), 400
        try:
            datetime.datetime.strptime(date_str, "%Y-%m-%d")
        except Exception:
            return jsonify({"error": "Invalid date format. Use YYYY-MM-DD."}), 400
        if persons < 1 or persons > 6:
            return jsonify({"error": "persons must be between 1 and 6"}), 400
        if len(person_details) < persons:
            return jsonify({"error": "person_details must contain details for each person"}), 400

        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor()

        # generate unique booking_ref
        booking_ref = ensure_unique_booking_ref(conn)

        cursor.execute(
            "INSERT INTO bookings (booking_ref, title, booking_date, time_slot, persons, amount, paid) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (booking_ref, title, date_str, time_slot, persons, amount, False)
        )
        booking_id = cursor.lastrowid

        for i in range(persons):
            p = person_details[i] if i < len(person_details) else {}
            cursor.execute(
                "INSERT INTO persons (booking_id, name, phone, gender, age, is_elder_disabled, elder_age, wheelchair_required) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
                (
                    booking_id,
                    p.get("name"),
                    p.get("phone"),
                    p.get("gender"),
                    p.get("age"),
                    bool(p.get("is_elder_disabled", False)),
                    p.get("elder_age"),
                    (p.get("wheelchair_required") if "wheelchair_required" in p else None)
                )
            )

        conn.commit()
        cursor.close()
        conn.close()

        # Insert notification: booking created (payment pending)
        insert_notification(
            title=f"{title} Booking Created",
            message=f"Your booking (Ref: {booking_ref}) for {date_str} at {time_slot} is created. Complete payment to confirm.",
            _type="booking_created",
            booking_id=booking_id
        )

        return jsonify({"success": True, "booking_id": booking_id, "booking_ref": booking_ref, "message": "Booking created (payment pending)"}), 201
    except Error as e:
        print(f"❌ Booking DB error: {e}")
        try:
            if conn:
                conn.rollback()
        except:
            pass
        return jsonify({"error": f"Database error: {str(e)}"}), 500
    except Exception as e:
        print(f"❌ Booking error: {e}")
        try:
            if conn:
                conn.rollback()
        except:
            pass
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/payment", methods=["POST"])
def payment():
    conn = None
    try:
        data = request.get_json(force=True)
        if not data:
            return jsonify({"error": "JSON body required"}), 400
        booking_id = int(data.get("booking_id", 0))
        amount = int(data.get("amount", 0))
        payment_ref = data.get("payment_ref", f"DEV-{random.randint(1000,9999)}")

        if booking_id <= 0:
            return jsonify({"error": "Valid booking_id required"}), 400

        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM bookings WHERE id=%s", (booking_id,))
        booking = cursor.fetchone()
        if not booking:
            cursor.close()
            conn.close()
            return jsonify({"error": "Booking not found"}), 404

        cursor.execute("UPDATE bookings SET paid=%s, amount=%s, payment_ref=%s WHERE id=%s", (True, amount, payment_ref, booking_id))
        conn.commit()
        cursor.execute("SELECT * FROM bookings WHERE id=%s", (booking_id,))
        updated = cursor.fetchone()
        cursor.close()
        conn.close()

        # Insert payment success notification
        insert_notification(
            title="Booking Payment Successful",
            message=f"Payment for booking Ref {updated.get('booking_ref', booking_id)} is successful. Amount: ₹{amount}.",
            _type="payment_success",
            booking_id=booking_id
        )

        return jsonify({"success": True, "booking": serialize_row(updated), "message": "Payment successful"}), 200
    except Error as e:
        print(f"❌ Payment DB error: {e}")
        try:
            if conn:
                conn.rollback()
        except:
            pass
        return jsonify({"error": f"Database error: {str(e)}"}), 500
    except Exception as e:
        print(f"❌ Payment error: {e}")
        try:
            if conn:
                conn.rollback()
        except:
            pass
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/notifications", methods=["GET"])
def notifications():
    try:
        limit = int(request.args.get("limit", 50))
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM notifications ORDER BY created_at DESC LIMIT %s", (limit,))
        notes = cursor.fetchall()
        out = []
        for n in notes:
            n_serial = serialize_row(n)
            bid = n.get('booking_id')
            if bid:
                c2 = conn.cursor(dictionary=True)
                c2.execute("SELECT name, phone FROM persons WHERE booking_id=%s", (bid,))
                persons = c2.fetchall()
                c2.close()
                for p in persons:
                    if 'name' in p and isinstance(p['name'], (bytes, bytearray)):
                        p['name'] = p['name'].decode('utf-8')
                n_serial['person_details'] = persons
            out.append(n_serial)
        cursor.close()
        conn.close()
        return jsonify({"notifications": out}), 200
    except Exception as e:
        print(f"❌ Notifications error: {e}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/notifications/<int:notification_id>/read", methods=["PUT"])
def mark_notification_read(notification_id):
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor()
        cursor.execute("UPDATE notifications SET is_read=TRUE WHERE id=%s", (notification_id,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"success": True, "message": "Notification marked as read"}), 200
    except Exception as e:
        print(f"❌ mark_notification_read error: {e}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/history", methods=["GET"])
def history():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM bookings ORDER BY created_at DESC")
        bookings = cursor.fetchall()
        out = []
        for b in bookings:
            bid = b['id']
            c2 = conn.cursor(dictionary=True)
            c2.execute("SELECT * FROM persons WHERE booking_id=%s", (bid,))
            persons = c2.fetchall()
            c2.close()
            b_serial = serialize_row(b)
            b_serial['person_details'] = [serialize_row(p) for p in persons]
            out.append(b_serial)
        cursor.close()
        conn.close()
        return jsonify({"history": out}), 200
    except Exception as e:
        print(f"❌ History error: {e}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/history/user", methods=["GET"])
def history_user():
    """
    GET /history/user?phone=9876543210
    Returns bookings where any person.phone matches the provided phone.
    """
    try:
        phone = request.args.get("phone", None)
        if not phone:
            return jsonify({"error": "phone query parameter is required"}), 400

        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500

        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT DISTINCT booking_id FROM persons WHERE phone=%s", (phone,))
        rows = cursor.fetchall()
        booking_ids = [r['booking_id'] for r in rows] if rows else []

        if not booking_ids:
            cursor.close()
            conn.close()
            return jsonify({"history": []}), 200

        placeholders = ",".join(["%s"] * len(booking_ids))
        query = f"SELECT * FROM bookings WHERE id IN ({placeholders}) ORDER BY created_at DESC"
        cursor.execute(query, tuple(booking_ids))
        bookings = cursor.fetchall()
        out = []
        for b in bookings:
            bid = b['id']
            c2 = conn.cursor(dictionary=True)
            c2.execute("SELECT * FROM persons WHERE booking_id=%s", (bid,))
            persons = c2.fetchall()
            c2.close()
            b_serial = serialize_row(b)
            b_serial['person_details'] = [serialize_row(p) for p in persons]
            out.append(b_serial)
        cursor.close()
        conn.close()
        return jsonify({"history": out}), 200

    except Exception as e:
        print(f"❌ History user error: {e}")
        try:
            conn.rollback()
        except:
            pass
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/booking/<int:booking_id>", methods=["GET"])
def get_booking(booking_id):
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM bookings WHERE id=%s", (booking_id,))
        booking = cursor.fetchone()
        if not booking:
            cursor.close()
            conn.close()
            return jsonify({"error": "Booking not found"}), 404
        cursor2 = conn.cursor(dictionary=True)
        cursor2.execute("SELECT * FROM persons WHERE booking_id=%s", (booking_id,))
        persons = cursor2.fetchall()
        cursor2.close()
        cursor.close()
        conn.close()
        booking_serial = serialize_row(booking)
        booking_serial['person_details'] = [serialize_row(p) for p in persons]
        return jsonify({"booking": booking_serial}), 200
    except Exception as e:
        print(f"❌ Get booking error: {e}")
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/booking/<int:booking_id>/qr", methods=["GET"])
def booking_qr(booking_id):
    """
    Returns qr_payload:
    { "qr_payload": { "booking_id": 1, "booking_ref": "BK-...", "amount": 200, "payment_ref": "QR-abc123", "paid": false } }
    """
    conn = None
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, booking_ref, amount, paid, payment_ref FROM bookings WHERE id=%s", (booking_id,))
        booking = cursor.fetchone()
        if not booking:
            cursor.close()
            conn.close()
            return jsonify({"error": "Booking not found"}), 404

        payment_ref = booking.get("payment_ref")
        if not payment_ref:
            payment_ref = f"QR-{uuid.uuid4().hex[:12]}"
            cursor.execute("UPDATE bookings SET payment_ref=%s WHERE id=%s", (payment_ref, booking_id))
            conn.commit()

        payload = {
            "booking_id": booking_id,
            "booking_ref": booking.get("booking_ref"),
            "amount": int(booking.get("amount", 0)),
            "payment_ref": payment_ref,
            "paid": bool(booking.get("paid", False))
        }
        cursor.close()
        conn.close()
        return jsonify({"qr_payload": payload}), 200
    except Exception as e:
        print(f"❌ booking_qr error: {e}")
        try:
            if conn:
                conn.rollback()
        except:
            pass
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/dev/clear-bookings", methods=["POST"])
def clear_bookings():
    try:
        conn = get_db_connection()
        if not conn:
            return jsonify({"error": "Database not connected"}), 500
        cursor = conn.cursor()
        cursor.execute("DELETE FROM persons")
        cursor.execute("DELETE FROM bookings")
        cursor.execute("DELETE FROM notifications")
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({"success": True, "message": "All bookings & notifications cleared (DEV)"}), 200
    except Exception as e:
        print(f"❌ Clear bookings error: {e}")
        try:
            conn.rollback()
        except:
            pass
        return jsonify({"error": f"Server error: {str(e)}"}), 500

# ---------- RUN APP ----------
if __name__ == "__main__":
    print("🚀 Starting Divya Drishti Flask server...")
    print("📍 DEVELOPMENT MODE: Dummy OTP Enabled")
    print("📍 Test server at: http://127.0.0.1:5000/")
    print("🔄 Setting up database tables...")
    create_tables()
    app.run(debug=True, host="0.0.0.0", port=5000)
