import sys
print(sys.executable)
import pymysql
from dotenv import load_dotenv
import os
from flask import Flask, jsonify, request
from flask import g

app = Flask(__name__)


def get_db():
    if 'db' not in g:
        g.db = home()
    return g.db

# Members AIP Route
@app.route('/members', methods=['GET'])
def members():
    return {"members": ["member1", "member2", "member3"]}

def home():
    load_dotenv()
    username = os.getenv("DB_USERNAME")
    password_ = os.getenv("DB_PASSWORD")
    try:
        connection = pymysql.connect(
            host="localhost",
            user=username,
            password=password_,
            database="jobfinder",
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True
        )
        g.db = connection
        print("connection madee")
        return "Database connection success"
    except pymysql.Error as e:
        code, msg = e.args
        print("failed to connect to mySQL database")
        return None

@app.route('/')
def index():
    return home()

@app.route('/checkUser', methods=['POST'])
def checkUser():
    print("check user called")
    username = request.json.get('username')
    password = request.json.get('password')
    connection = get_db()
    if connection:
        c1 = connection.cursor()
        # %s used to prevent SQL injection vulnerability
        query = "SELECT is_returning_user(%s,%s)"
        c1.execute(query, (username, password))
        result = c1.fetchone()
        return jsonify({"message": "checkUser successful", "result": result})
    else:
        return jsonify({"message": "Database connection failed"}), 500

@app.teardown_appcontext
def close_db(e):
    db = g.pop('db', None)
    if db is not None:
        db.close()


if __name__ == "__main__":
    print("main")
    app.run(debug=True)
