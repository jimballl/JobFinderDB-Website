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
            query = "CALL add_user(%s,%s,%s,%s,%s, %s)"
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
        return jsonify({"message": "No Companies Found"}), 500

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
        return jsonify({"message": "No Companies Found"}), 500

@app.route('/UpdateUsername', methods=['POST'])
def UpdateUsername():
    username = request.json.get('username')
    new_username = request.json.get('new_username')
    print("username: ", username, "new_username: ", new_username)
    connection = get_db()
    if connection:
        with connection.cursor() as cursor:
            cursor.callproc('update_username', [new_username, username])
            return jsonify({"message": "Username Updated", "result": True})
    else:
        return jsonify({"message": "Username Change Not Possible", "result": False}), 500

@app.route('/deleteUser', methods=['DELETE'])
def deleteUser():
    username = request.json.get('username')
    connection = get_db()
    if connection:
        with connection.cursor() as cursor:
            cursor.callproc('delete_user', [username])
            return jsonify({"message": "User Deleted", "result": True})
    else:
        return jsonify({"message": "User Deletion Not Possible", "result": False}), 500

@app.route('/past_employees', methods=['GET'])
def get_past_employees():
    print("getPastEmployees called")
    company = request.args.get('company')
    print("Company: ", company)
    connection = get_db()
    if connection:
        with connection.cursor() as cursor:
            cursor.execute('CALL get_past_employees(%s)', [company])
            results = cursor.fetchall()
            print("Results: ", results)
            if not results:
                return jsonify({"message": f"No past employees found for {company}"}), 404
            return jsonify(results)
    else:
        return jsonify({"message": "Database connection failed"}), 500


@app.route('/create_job', methods=['POST'])
def create_job():
    print("createJob called")
    job_data = request.get_json()
    input_names = ["Job-Title-Input", "Job-Catalogue-Input", "Job-Description-Input", "Work-Setting-Input", "Employment-Type-Input", "Company-Name-Input"]
    job_data = {key: job_data.get(key) for key in input_names}
    connection = get_db()
    if connection:
        try:
            with connection.cursor() as cursor:
                cursor.callproc('create_job', list(job_data.values()))
                job_id = cursor.fetchone()
                print("Job created with ID: ", job_id)
                return jsonify({"message": f"Job created with ID: {job_id}", "id": job_id})
        except pymysql.Error as e:
            print("Failed to create job", e)
            return jsonify({"message": "Failed to create job"}), 500
    else:
        return jsonify({"message": "Database connection failed"}), 500

@app.teardown_appcontext
def close_db():
    db = g.pop('db', None)
    if db is not None:
        db.close()


if __name__ == "__main__":
    print("main")
    app.run(debug=True)
