import sys
print(sys.executable)
import pymysql
from dotenv import load_dotenv
import os
from flask import Flask, jsonify, request
from flask import g
from flask_cors import CORS
import sqlite3

app = Flask(__name__)
cors= CORS(app, origins=["*"])


def get_db():
    if 'db' not in g:
        g.db = home()
    print("get_db called")
    return g.db


def home():
  load_dotenv()
  print("home called")
  username = os.getenv("DB_USERNAME")
  password_ = os.getenv("DB_PASSWORD")

  # Connect to MySQL database (assuming successful environment variable retrieval)
  try:
    connection = pymysql.connect(
        host="localhost",
        user=username,
        password=password_,
        database="jobfinder",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True
    )
  except Exception as e:
    print("Error connecting to MySQL database:", e)
    return None  # Indicate connection failure

#   # Execute SQL commands from JobFinderDB.sql (assuming MySQL connection successful)
#   with open("JobFinderDB.sql", "r") as f:
#     try:
#       cursor = connection.cursor()
#       for line in f:
#         line = line.strip()
#         if line and not line.startswith("--"):  # Skip comments
#           cursor.execute(line)
#       connection.commit()  # Commit changes after all commands are executed
#     except pymysql.Error as e:
#       print("Failed to execute SQL commands:", e)
  
  print("connection made")
  return connection


@app.route('/')
def index():
    print("index called")
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
        
    
@app.route('/companies_in_country', methods=['GET'])
def companies_in_country():
    country_name = request.args.get('country')
    print(f"Country name: {country_name}")  # print the country name
    connection = get_db()
    if connection:
        with connection.cursor() as cursor:
            cursor.execute('CALL find_companies_in_country(%s)', [country_name])
            results = cursor.fetchall()
            print(f"Results: {results}")  # print the results
            return jsonify(results)
    else:
        print("Database connection failed")  # print an error message
        return jsonify({"message": "Database connection failed"}), 500

@app.route('/companies_within_salary', methods=['GET'])
def companies_within_salary():
    min_salary = request.args.get('min_salary')
    max_salary = request.args.get('max_salary')
    connection = get_db()
    if connection:
        with connection.cursor() as cursor:
            cursor.callproc('find_companies_within_salary', [min_salary, max_salary])
            results = cursor.fetchall()
            print(results)
            return jsonify(results)
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
