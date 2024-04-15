import sys
print(sys.executable)
import pymysql
from dotenv import load_dotenv
import os
from flask import Flask, jsonify, request
from flask import g
from flask_cors import CORS

app = Flask(__name__)
cors= CORS(app, origins=["*"])


def get_db():
    if 'db' not in g:
        g.db = home()
    print("get_db called")
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
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True
        )

        # Create jobfinder database if it doesn't exist
        try:
            with connection.cursor() as cursor:
                cursor.execute("CREATE DATABASE IF NOT EXISTS jobfinder")
        finally:
            connection.close()

        # Connect to jobfinder database
        connection = pymysql.connect(
            host="localhost",
            user=username,
            password=password_,
            database="jobfinder",
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True
        )

        print("connection made")
        return connection
    except pymysql.Error as e:
        code, msg = e.args
        print("failed to connect to mySQL database", e)
        return "Database connection failed"

@app.route('/')
def index():
    return home()

@app.route('/checkUser', methods=['GET'])
def checkUser():
    print("check user called")
    username = request.args.get('username')
    password = request.args.get('password')
    print("username: ", username)
    print("password: ", password)
    connection = get_db()
    if connection:
        print("connection: ", connection)
        c1 = connection.cursor()
        # %s used to prevent SQL injection vulnerability
        query = "SELECT is_returning_user(%s,%s)"
        c1.execute(query, (username, password))
        result = c1.fetchone()
        # allows us to grab the value associated with the result of the query
        key = "is_returning_user('{}','{}')".format(username, password)
        print(key)
        if result[key] == 1:
            return jsonify({"message": "login successful :)", "result": True})
        else:
            return jsonify({"message": "login unsuccessful :(", "result": False})
    else:
        return jsonify({"message": "Database connection failed"}), 500
    
@app.route('/signUp', methods=['POST'])
def signUpUser():
    print("signUp called")
    username = request.json.get('username')
    password = request.json.get('password')
    ssn = request.json.get('ssn')
    name = request.json.get('name')
    sex = request.json.get('sex')
    yoe = request.json.get('years_of_experience')

    connection = get_db()
    print("connection: ", connection)
    if connection:
        try:
            c2 = connection.cursor()
            query = "CALL AddUser(%s,%s,%s,%s,%s, %s)"
            print("username: ", username, "password: ", password, "ssn: ", ssn, "name: ", name, "sex: ", sex, "years_of_experience: ", yoe)
            c2.execute(query, (username, password, ssn, name, sex, yoe))
            print("add user called")
            return jsonify({"message": "Signup successful"})
        except pymysql.Error as e:
            print("Failed to signup", e)
            return jsonify({"message": "Failed to signup"}), 500
    else:
        print("Database connection failed")
        return jsonify({"message": "Database connection failed"}), 500
        
    

@app.teardown_appcontext
def close_db(e):
    db = g.pop('db', None)
    if db is not None:
        db.close()


if __name__ == "__main__":
    print("main")
    app.run(debug=True)
