drop database if exists jobfinder;
create database jobfinder;

use jobfinder;

drop table if exists JobSeeker;
CREATE TABLE JobSeeker (
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
    passwrd VARCHAR(50) check (char_length(passwrd)>4),
    SSN INT NOT NULL,
    join_date DATE default '2024-04-13',
    PRIMARY KEY (username, passwrd),
    FOREIGN KEY (SSN) REFERENCES JobSeeker(SSN) 
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

drop table if exists Job;
CREATE TABLE Job (
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
    FOREIGN KEY (ID) REFERENCES Job(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists Country;
CREATE TABLE Country (
    name VARCHAR(100) PRIMARY KEY,
    population_size INT NOT NULL,
    freedom_index DECIMAL(5,2) NOT NULL
);

drop table if exists PastEmployee;
CREATE TABLE PastEmployee (
    ID INT PRIMARY KEY,
    work_years INT NOT NULL,
    experience INT NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (country_name) REFERENCES Country(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (company_name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists Job_PastEmployee;
CREATE TABLE Job_PastEmployee (
    Job_ID INT,
    PastEmployee_ID INT NOT NULL,
    PRIMARY KEY (Job_ID, PastEmployee_ID),
    FOREIGN KEY (Job_ID) REFERENCES Job(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PastEmployee_ID) REFERENCES PastEmployee(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists Company_Country;
CREATE TABLE Company_Country (
    Company_Name VARCHAR(100),
    Country_Name VARCHAR(100),
    PRIMARY KEY (Company_Name, Country_Name),
    FOREIGN KEY (Company_Name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Country_Name) REFERENCES Country(name) ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists User_Job;
CREATE TABLE User_Job (
    Job_ID INT,
    username VARCHAR(50),
    passwrd VARCHAR(50),
    PRIMARY KEY (Job_ID, username, passwrd),
    FOREIGN KEY (Job_ID) REFERENCES Job(ID) ON DELETE CASCADE ON UPDATE CASCADE,
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
DROP PROCEDURE IF EXISTS AddUser;
DELIMITER $$
CREATE PROCEDURE AddUser(
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
DROP PROCEDURE IF EXISTS DeleteUser;
DELIMITER $$
CREATE PROCEDURE DeleteUser(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(50)
)
BEGIN
	delete from user
    where username = p_username and passwrd = p_password;
END $$
DELIMITER ;

-- Update name a job seeker name on their profile 
DROP PROCEDURE IF EXISTS UpdateName;
DELIMITER $$
CREATE PROCEDURE UpdateName(
    IN p_new_name VARCHAR(50),
    IN p_SSN int
)
BEGIN
	update jobseeker
    set name = p_new_name
    where p_SSN = SSN;
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
    
SELECT is_returning_user('Lucas', 'Kirma');
SELECT is_returning_user('Lucas', 'Kirma');
INSERT INTO jobseeker(SSN, name, sex, experience)
		VALUES ('0000', 'Lucas', 'm', 5);
INSERT INTO User(username, passwrd, SSN)
		VALUES ('Lucas', 'Kirma', 0000);



-- Create Countries 
INSERT INTO country(name, population_size, freedom_index)
		VALUES ('USA', 300000000, 5.5);
INSERT INTO country(name, population_size, freedom_index)
		VALUES ('Brazil', 500000000, 4.0);
INSERT INTO country(name, population_size, freedom_index)
		VALUES ('China', 1000000000, 2.1); 
INSERT INTO country(name, population_size, freedom_index)
		VALUES ('Russia', 200000000, 1.1); 

-- Create Companies 
INSERT INTO company( name, Industry, C_Rank, Revenue, Revenue_Growth)
		VALUES ('Apple', 'Tech', 3, 1000000, 10.5);
INSERT INTO company( name, Industry, C_Rank, Revenue, Revenue_Growth)
		VALUES ('JasperInc', 'Agriculture', 2, 10000000, 100.5);
INSERT INTO company( name, Industry, C_Rank, Revenue, Revenue_Growth)
		VALUES ('LucasInc', 'Commodities', 4, 100000, 9.5);
INSERT INTO company( name, Industry, C_Rank, Revenue, Revenue_Growth)
		VALUES ('BrazilTrees', 'Non-Profit', 1, 1001000, 19.5);

-- Create company_country
INSERT INTO company_country(Company_Name, Country_Name)
		VALUES ('Apple', 'USA');  
INSERT INTO company_country(Company_Name, Country_Name)
		VALUES ('JasperInc', 'Russia');
INSERT INTO company_country(Company_Name, Country_Name)
		VALUES ('LucasInc', 'Brazil');
INSERT INTO company_country(Company_Name, Country_Name)
		VALUES ('BrazilTrees', 'Brazil');
        
-- Create Jobs
INSERT INTO job(ID, job_title, job_catalogue, description, work_setting, employment_type, name)
	values(1, 'Manager', 'xxx', 'Manage trees', 'field', 'on-site', 'BrazilTrees'); 
INSERT INTO job(ID, job_title, job_catalogue, description, work_setting, employment_type, name)
	values(2, 'CFO', 'xxx', 'Manage finance department', 'corporate', 'hybrid', 'JasperInc'); 
INSERT INTO job(ID, job_title, job_catalogue, description, work_setting, employment_type, name)
	values(3, 'Associate analyst', 'xxx', 'analyze strategy', 'corporate', 'remote', 'LucasInc'); 
INSERT INTO job(ID, job_title, job_catalogue, description, work_setting, employment_type, name)
	values(4, 'Developer', 'xxx', 'develop software', 'corporate', 'hybrid', 'Apple'); 

-- Create Salaries 
INSERT INTO salary(salary_currency, salary_in_usd, ID)
	values('BRL', 80000, 3);
INSERT INTO salary(salary_currency, salary_in_usd, ID)
	values('BRL', 90000, 1);
INSERT INTO salary(salary_currency, salary_in_usd, ID)
	values('RUB', 200000, 2);
INSERT INTO salary(salary_currency, salary_in_usd, ID)
	values('USD', 160000, 4);

        
-- View Tables
select * from jobseeker;
select * from user;
select * from country;
select * from company;
select * from company_country;
select * from job;
select * from salary;

-- Test Procedures
call AddUser('Lucas', 'Kirma', 0000, 'LucasKirma', 'Y', 100);
call AddUser('Jasper', 'Kimbal', 1000, 'LucasKirma', 'Y', 100);
call AddUser('Jasperl', 'Kimball', 1000, 'JAsper', 'Y', 100);

call find_companies_in_country('USA');
call find_companies_in_country('Brazil');
call find_companies_in_country('Russia');
call find_companies_in_country('China');

call find_companies_within_salary(0, 160000);

call DeleteUser('Jasperl', 'Kimball');

call UpdateName('Jasper Kimball', 0000);


-- example code for triggers  
/*
-- drop trigger if exists attack_after_insert;
-- delimiter $$
-- create trigger attack_after_insert
-- 	after insert on attack
--     for each row 
--     begin
--     update township set num_attacks = num_attacks + 1
--     where tid = new.location;
--     end$$
-- delimiter ;
*/
