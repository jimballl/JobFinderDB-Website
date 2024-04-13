drop database if exists jobfinder;
create database jobfinder;

use jobfinder;

CREATE TABLE JobSeeker (
    SSN INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sex CHAR(1) NOT NULL,
    experience INT NOT NULL
);

CREATE TABLE User (
    username VARCHAR(50),
    passwrd VARCHAR(50),
    SSN INT NOT NULL,
    PRIMARY KEY (username, passwrd),
    FOREIGN KEY (SSN) REFERENCES JobSeeker(SSN) 
    ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Company (
    name VARCHAR(100) PRIMARY KEY,
    Industry VARCHAR(100) NOT NULL,
    C_Rank INT NOT NULL,
    Revenue DECIMAL(15,2) NOT NULL,
    Revenue_Growth DECIMAL(5,2) NOT NULL
);

CREATE TABLE Job (
    ID INT PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    job_catalogue VARCHAR(100) NOT NULL,
    description VARCHAR(150),
    work_setting VARCHAR(100) NOT NULL,
    employment_type VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE
);

-- salary is a weak entity and does not have a primary key 
CREATE TABLE Salary (
    salary_currency CHAR(3) NOT NULL,
    salary_in_usd DECIMAL(10,2) NOT NULL,
    ID INT NOT NULL,
    FOREIGN KEY (ID) REFERENCES Job(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Country (
    name VARCHAR(100) PRIMARY KEY,
    population_size INT NOT NULL,
    freedom_index DECIMAL(5,2) NOT NULL
);

CREATE TABLE PastEmployee (
    ID INT PRIMARY KEY,
    work_years INT NOT NULL,
    experience INT NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (country_name) REFERENCES Country(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (company_name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Job_PastEmployee (
    Job_ID INT,
    PastEmployee_ID INT NOT NULL,
    PRIMARY KEY (Job_ID, PastEmployee_ID),
    FOREIGN KEY (Job_ID) REFERENCES Job(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PastEmployee_ID) REFERENCES PastEmployee(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Company_Country (
    Company_Name VARCHAR(100),
    Country_Name VARCHAR(100),
    PRIMARY KEY (Company_Name, Country_Name),
    FOREIGN KEY (Company_Name) REFERENCES Company(name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Country_Name) REFERENCES Country(name) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE User_Job (
    Job_ID INT,
    username VARCHAR(50),
    passwrd VARCHAR(50),
    PRIMARY KEY (Job_ID, username, passwrd),
    FOREIGN KEY (Job_ID) REFERENCES Job(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (username, passwrd) REFERENCES User(username, passwrd) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Check if a user exists to send into their account or if it doesnt, then they need to create one    
DELIMITER $$
CREATE PROCEDURE IsReturningUser(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(50)
)
BEGIN
	declare output int;
    if exists ( select 1 from users as u where u.username = p_username and u.passwrd = p_password) then 
		set output = -1;
    else
		signal sqlstate '45000' set message_text = 'This account does not exist. Please go back and create a username and password';
    end if;
    return (output);
    
END $$
DELIMITER ;

-- Create a user on the front end means creating a "job seeker" and a "User" on the back end
DELIMITER $$
CREATE PROCEDURE AddUser(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(50),
    IN SSN int
)
BEGIN
	declare is_existing_user int;
    call IsReturningUser(p_username, p_password) into is_existing_user;
    
	if is_existing_user = -1 then 
		singnal sqlstate '45000' set message_text = 'User already exists. Try another username and password';
	else
		INSERT INTO User(username, passwrd)
		VALUES (p_username, p_password);
	end if;
END $$
DELIMITER ;

drop trigger if exists attack_after_insert;
delimiter $$
create trigger attack_after_insert
	after insert on attack
    for each row 
    begin
    update township set num_attacks = num_attacks + 1
    where tid = new.location;
    end$$
delimiter ;
