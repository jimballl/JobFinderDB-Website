use jobfinder;

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
