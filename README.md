
# Data Science Job Finder Web App
## Database project - Replicating Job Seeking Database Using Online Datasets

### To run code
#### Prerequisites

- [Python3](https://www.python.org/downloads/)
- MySQL server up and running on a computer
- Optional: [VSCode](https://code.visualstudio.com/download) and [VSCode Live Extension](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)

#### MySQL Setup

1. Install MySQL Server if not installed. You can download it from the [official MySQL website](https://dev.mysql.com/downloads/mysql/).
2. Start the MySQL server. The command to do this will depend on your operating system. On Windows, you can start it from the MySQL Installer. On macOS and Linux, you can usually start it with the command `sudo service mysql start`.

#### Installation (Tested on Windows, but commands should be similar on Linux/Mac)

1. Download or Clone this repository: `git clone ...`
2. Navigate to the project directory in your terminal: `cd ~/JobFinderDB-Project`
3. In bash run: `pip3` or `pip install -r requirements.txt` (ignore any errors for now)
4. Create a new file in `/backend` named `.env` and fill in your credentials as follows:

```bash
DB_USERNAME=[Insert your MySQL username]
DB_PASSWORD=[Insert your MySQL password]
```
example:
```bash
DB_USERNAME=root
DB_PASSWORD=root
```

#### Setting up MySQL

Run the entire `backend/JobFinderDB.sql` script within your MySQL application

#### Running the Server

Run the backend by running `python3 backend/server.py` or `python backend/server.py`. You should see the message "Server is running on port 5000" in the console.

If you see any missing installation, use pip to install any of them. Examples include (`pip install Flask`, `pip install flask_cors`, `pip install python-dotenv`)

#### Running the Frontend

Navigate to the `frontend/HTML/index.html` and run the Live Server extension in VSCode (bottom right of VSCode).

Alternatively you could try running `python -m http.server` in `frontend/HTML`, but the resulting UI may be off.

Then, enter `localhost:8000` into the address bar of your browser.


#### To use the website:
You can either log in on admin (username:`admin`, password: `admin`)... which will give you access to admin CRUD operations.

Or you can sign up with an account (don't forget your username and password)... which will give you standard job seeker CRUD operations.


---


### A top-level description of the project.
Our fellow data science students are looking for post-graduation work. They are struggling to a good fit, but luckily they can become users of a database that tracks open jobs. These jobs are associated with past employees and previous salaries. Users can compare job salaries across companies to see if their expertise matches previous employees’ skill sets or salary expectations. Furthermore, Users will be able to see which companies these jobs belong to, which countries they are in, and where the previous employees lived (there may be hybrid, remote, or in-person) options. 


### A top-level description of the data to be stored in the database.
Job Seeker Entity: This entity represents a job seeker in the real world. The attributes include SSN (primary key), name, sex, and experience. Job seekers can create many accounts, establishing a one-to-many (1..*) multiplicity with the User.
User Entity: This entity represents the users of the job search system. The attributes include username (partial primary key) and password (partial primary key). Each user can look for multiple jobs, establishing a zero-to-many (0..*) multiplicity with the Job entity. Each user can be created by one job seeker, establishing a 1..1 multiplicity with the Job Seeker entity.
Job Entity: This entity represents the jobs available in the system. The attributes include ID (primary key), job_catalogue, job_title, description, work_setting, and employment_type. The entity is linked to the User entity (users looking for jobs) where jobs can be looked at by 0 or many users creating a zero-to-many (0..*) multiplicity. This entity is linked to the Company entity (companies providing jobs), establishing a one-to-one (1..1) multiplicity. Each job has an associated salary, establishing a one-to-one (1..1) multiplicity with the Salary entity. Each job can also have been worked at by one-to-many (0..*) past employees.
Salary Entity: This weak entity represents the salary information for each job. It is fully dependent on the specific job. The attributes include salary_currency and salary_in_usd. The data for this entity can be populated from the “Data Science Salary” dataset. Each salary is associated with one job, establishing a one-to-one (1..1) multiplicity with the Job entity.
Company Entity: This entity represents companies in the real world. The attributes include Name (primary key), Industry, Rank, Revenue, and Revenue Growth. The data for this entity can be populated from the “100 largest companies” dataset. Each company can provide multiple jobs, establishing a one-to-many (1...*) multiplicity with the Job entity. A company can be located in many countries, establishing a one-to-many (1..*) relationship with the Country entity.


Past Employee Entity: This entity represents the past employees of the companies. The salary data will be populated with the “Data Science Salary” dataset. The attributes include ID (primary key), work_years, and experience. Each past employee worked in a designated county, providing (1..1) multiplicity with the Country entity. Each past employee had 1 or multiple past jobs, and a job could have 0 or many past employees, establishing a many-to-many (M:M) relationship with the Job entity.
Country Entity: This entity represents the countries where companies are located and where past employees have worked. The attributes include name (primary key), population size, and freedom index. The data for this entity can be populated from the “Country Population Data” dataset. Each country can have multiple companies and past employees, establishing a zero-to-many (0..*) multiplicity with both the Company and Past Employee entities.
