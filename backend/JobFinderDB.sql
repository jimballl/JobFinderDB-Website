drop database if exists jobfinder;

create database jobfinder;

use jobfinder;

drop table if exists jobseeker;
CREATE TABLE jobseeker(
    SSN INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sex CHAR(1) NOT NULL,
    experience INT NOT NULL,
	account_num int default 0
);

-- create user table and make sure password length is greater than 4
drop table if exists User;
CREATE TABLE User (
    username VARCHAR(50),
    passwrd VARCHAR(50) check (char_length(passwrd)>2),
    SSN INT NOT NULL,
    join_date DATE default '2024-04-13',
    PRIMARY KEY (username, passwrd),
    FOREIGN KEY (SSN) REFERENCES jobseeker(SSN) 
    ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists Company;
CREATE TABLE Company (
    name VARCHAR(100) PRIMARY KEY,
    Industry VARCHAR(100) NOT NULL,
    C_Rank INT NOT NULL,
    Revenue DECIMAL(15,2) NOT NULL,
    Revenue_Growth DECIMAL(5,2) NOT NULL
);

drop table if exists job;
CREATE TABLE job (
    ID INT PRIMARY KEY auto_increment,
    job_title VARCHAR(100) NOT NULL,
    job_catalogue VARCHAR(100) NOT NULL,
    description VARCHAR(150),
    work_setting VARCHAR(100) NOT NULL,
    employment_type VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE
);

-- salary is a weak entity and does not have a primary key 
drop table if exists Salary;
CREATE TABLE Salary (
    salary_currency CHAR(3) NOT NULL,
    salary_in_usd DECIMAL(10,2) NOT NULL,
    ID INT NOT NULL,
    FOREIGN KEY (ID) REFERENCES job(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists Country;
CREATE TABLE Country (
    name VARCHAR(100) PRIMARY KEY,
    population_size INT NOT NULL,
    freedom_index DECIMAL(5,2) NOT NULL
);

drop table if exists past_employee;
CREATE TABLE past_employee (
    ID INT PRIMARY KEY,
    work_years INT NOT NULL,
    experience INT NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (country_name) REFERENCES Country(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (company_name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists job_past_employee;
CREATE TABLE job_past_employee (
    job_ID INT,
    past_employee_ID INT NOT NULL,
    PRIMARY KEY (job_ID, past_employee_ID),
    FOREIGN KEY (job_ID) REFERENCES job(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (past_employee_ID) REFERENCES past_employee(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists company_country;
CREATE TABLE company_country (
    Company_Name VARCHAR(100),
    Country_Name VARCHAR(100),
    PRIMARY KEY (Company_Name, Country_Name),
    FOREIGN KEY (Company_Name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Country_Name) REFERENCES Country(name) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists user_job;
CREATE TABLE user_job (
    job_ID INT,
    username VARCHAR(50),
    passwrd VARCHAR(50),
    PRIMARY KEY (job_ID, username, passwrd),
    FOREIGN KEY (job_ID) REFERENCES job(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (username, passwrd) REFERENCES User(username, passwrd) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Check if a user exists to send into their account or if it doesnt, then they need to create one    
DROP FUNCTION IF EXISTS is_returning_user;
DELIMITER $$
CREATE FUNCTION is_returning_user(p_username varchar(50), p_password varchar(50)) 
	RETURNS INT
	deterministic 
	READS SQL DATA
	BEGIN
	declare output int;
    if exists ( select 1 from user as u where u.username = p_username and u.passwrd = p_password) then 
		set output = 1;
    else
		set output = -1;
    end if;
    return (output);
    
	END $$
DELIMITER ;

-- Check if a jobseeker already exists (useful for if they are creating more than one account)    
DROP FUNCTION IF EXISTS is_returning_jobseeker;
DELIMITER $$
CREATE FUNCTION is_returning_jobseeker(p_SSN int) 
	RETURNS INT
	deterministic 
	READS SQL DATA
	BEGIN
	declare output int;
    if exists ( select 1 from jobseeker as js where js.SSN = p_SSN) then 
		set output = 1;
    else
		set output = -1;
    end if;
    return (output);
    
	END $$
DELIMITER ;

-- Create a user on the front end means creating a "job seeker" and a "User" on the back end
DROP PROCEDURE IF EXISTS add_user;
DELIMITER $$
CREATE PROCEDURE add_user(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(50),
    IN p_SSN int,
    IN p_name VARCHAR(50),
    IN p_sex CHAR(1),
    IN p_experience int
)
BEGIN
 	declare is_existing_user int;
    declare is_existing_jobseeker int;
    
    select is_returning_user(p_username, p_password) into is_existing_user;
    select is_returning_jobseeker(p_SSN) into is_existing_jobseeker;

	if is_existing_user = 1 then 
		signal sqlstate '45000' set message_text = 'User already exists. Try another username and password';
	elseif is_existing_jobseeker = 1 then
        INSERT INTO User(username, passwrd, SSN)
 		VALUES (p_username, p_password, p_SSN);
 	else
		INSERT INTO jobseeker(SSN, name, sex, experience)
		VALUES (p_SSN, p_name, p_sex, p_experience); 
        
 		INSERT INTO User(username, passwrd, SSN)
 		VALUES (p_username, p_password, p_SSN);

 	end if;
END $$
DELIMITER ;

-- Delete old accounts after 2 years
drop event if exists remove_old_users;
DELIMITER $$
create event remove_old_users
on schedule every 1 day
do
	delete from user
    where join_date < date_sub(curdate(), interval 2 year);

DELIMITER ;

-- Delete user if you are done with it 
DROP PROCEDURE IF EXISTS delete_user;
DELIMITER $$
CREATE PROCEDURE delete_user(
    IN p_username VARCHAR(50)
)
BEGIN
	delete from user
    where username = p_username;
END $$
DELIMITER ;

-- Update a username name of an account 
DROP PROCEDURE IF EXISTS update_username;
DELIMITER $$
CREATE PROCEDURE update_username(
    IN p_new_name VARCHAR(50),
    IN p_old_name VARCHAR(50)
)
BEGIN
    UPDATE User
    SET username = p_new_name
    WHERE username = p_old_name;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No rows updated. The username does not exist or the new username is the same as the old one.';
    END IF;
END $$
DELIMITER ;

-- Decrement jobseeker account by one once a user is deleted
DROP TRIGGER IF EXISTS decrement_num_accounts;
DELIMITER $$
CREATE TRIGGER decrement_num_accounts
after delete on user
for each row 
begin
	update jobseeker 
    set account_num = account_num-1
    where SSN = old.SSN;
END$$
DELIMITER ;

-- Increment jobseeker account numbers when they make a new user
DROP TRIGGER IF EXISTS increment_num_accounts;
DELIMITER $$
CREATE TRIGGER increment_num_accounts
after insert on user
for each row 
begin
	update jobseeker 
    set account_num = account_num+1
    where SSN = new.SSN;
END$$
DELIMITER ;

-- Find all the companies within a country
DROP PROCEDURE IF EXISTS find_companies_in_country;
DELIMITER $$
CREATE PROCEDURE find_companies_in_country(IN p_country_name varchar(100))
	BEGIN
    select c.name, industry, c_rank, revenue, Revenue_Growth from company as c
    join company_country as cc on c.name = cc.Company_Name
    join country as cn on cn.name = cc.country_name 
    where cn.name = p_country_name;
END$$
DELIMITER ;	

-- Find companies and their job descriptions within a certain salary range
DROP PROCEDURE IF EXISTS find_companies_within_salary;
DELIMITER $$
CREATE PROCEDURE find_companies_within_salary(IN p_min_salary DECIMAL(10,2), IN p_max_salary DECIMAL(10,2))
	BEGIN
    select c.name as 'Company Name', j.job_title, j.description, industry, c_rank, revenue, Revenue_Growth from company as c
    join job as j on j.name = c.name
    join salary as s on s.ID = j.ID
    where s.salary_in_usd >= p_min_salary and s.salary_in_usd<=p_max_salary;
END$$
DELIMITER ;


/* Company Admin Procedures */

-- Create a new job posting and return its ID
DROP PROCEDURE IF EXISTS create_job;
DELIMITER $$
CREATE PROCEDURE create_job(
    IN p_job_title VARCHAR(100),
    IN p_job_catalogue VARCHAR(100),
    IN p_description VARCHAR(150),
    IN p_work_setting VARCHAR(100),
    IN p_employment_type VARCHAR(50),
    IN p_company_name VARCHAR(100),
    OUT p_job_id INT
)
BEGIN
    INSERT INTO job(job_title, job_catalogue, description, work_setting, employment_type, name)
    VALUES (p_job_title, p_job_catalogue, p_description, p_work_setting, p_employment_type, p_company_name);
    
    -- Get the ID of the newly created job
    SET p_job_id = LAST_INSERT_ID();
END $$
DELIMITER ;


-- Delete a job posting
DROP PROCEDURE IF EXISTS delete_job;
DELIMITER $$
CREATE PROCEDURE delete_job(
    IN p_ID INT
)
BEGIN
    DELETE FROM job WHERE ID = p_ID;
END $$
DELIMITER ;


-- Find all past employees, their job titles, departments, and salaries for a specific company
DROP PROCEDURE IF EXISTS get_past_employees_for_company;
DELIMITER $$
CREATE PROCEDURE get_past_employees_for_company(IN p_company_name VARCHAR(100))
BEGIN
    SELECT E.employee_name, J.job_title, D.department_name, S.salary_in_usd
    FROM past_employee E
    INNER JOIN job J ON E.job_id = J.ID
    INNER JOIN Departments D ON E.department_id = D.department_id
    INNER JOIN Salary S ON J.ID = S.ID
    WHERE E.end_date IS NOT NULL AND E.company_name = p_company_name;
END $$
DELIMITER ;

-- Prevents the user from updating to the protected ADMIN login
DROP TRIGGER IF EXISTS before_user_update;
DELIMITER $$
CREATE TRIGGER before_user_update
BEFORE UPDATE ON user
FOR EACH ROW
BEGIN
    IF NEW.username = 'admin' OR NEW.passwrd = 'admin' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot use "admin" as username or password.';
    END IF;
END $$
DELIMITER ;

-- Prevents the user from creating protected ADMIN login
DROP TRIGGER IF EXISTS before_user_update;
DELIMITER $$
CREATE TRIGGER before_user_update
BEFORE CREATE ON user
FOR EACH ROW
BEGIN
    IF NEW.username = 'admin' OR NEW.passwrd = 'admin' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot use "admin" as username or password.';
    END IF;
END $$
DELIMITER ;