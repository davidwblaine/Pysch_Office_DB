DROP SCHEMA psych_office_DB;   -- drops schema

-- temporarily disables contraints
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE psych_office_DB;
use psych_office_DB;


-- THE PERSON ENTITIES ARE BELOW
-- *==============================================================*

-- This table prevents all the PERSON information from needing to be
-- placed in: PATIENT, EMPLOYEE, HEALTHCARE_WORKER, INTERN, OFFICE_ADMIN
-- that saves 40 lines of code, and for look-up requires only merging 
-- these 5 tables

-- THIS SHOULD OCCUR AUTOMATICALLY ANYTIME A PERSON IS ENTERED INTO THE SYSTEM

CREATE TABLE IF NOT EXISTS PERSON (    
    -- see the details below here belong to every entity of type person
    -- imagine including these in every person entity, that is super redundant
    ssn INT NOT NULL, -- pk
	Fname VARCHAR(20) NOT NULL,
    Lname VARCHAR(20) NOT NULL,
	dob DATE NOT NULL,
	cellular VARCHAR(10) NOT NULL,
    street VARCHAR(20) NOT NULL,
	city VARCHAR(20) NOT NULL,
	state VARCHAR(20) NOT NULL,
	email VARCHAR(20) NOT NULL,
    PRIMARY KEY (ssn)
);

CREATE TABLE IF NOT EXISTS EMPLOYEE (
	employee_id INT NOT NULL, -- pk
    ssn INT NOT NULL, -- fk
    isMentor BOOLEAN NOT NULL,
	PRIMARY KEY (employee_id),
    FOREIGN KEY (ssn) REFERENCES PERSON (ssn)
);

-- REDID THIS TABLE, NOTICE
CREATE TABLE IF NOT EXISTS PATIENT (
	patient_id INT NOT NULL, -- pk
    ssn INT NOT NULL, -- fk
	PRIMARY KEY (patient_id),
	FOREIGN KEY (ssn) REFERENCES PERSON (ssn)
);

CREATE TABLE IF NOT EXISTS HEALTHCARE_WORKER (
	title VARCHAR(20),
	employee_id INT NOT NULL, -- fk
	no_patients INT NOT NULL,
	FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (employee_id)
);

-- every intern has a mentor
CREATE TABLE IF NOT EXISTS INTERN (
	employee_id INT NOT NULL, -- fk
    school_name VARCHAR(20),
    mentor_id INT NOT NULL, -- fk
    FOREIGN KEY(employee_id) REFERENCES EMPLOYEE (employee_id),
	FOREIGN KEY(mentor_id) REFERENCES EMPLOYEE (employee_id)
);

CREATE TABLE IF NOT EXISTS OFFICE_ADMIN (
	employee_id INT NOT NULL, -- fk
    has_degree BOOLEAN NOT NULL,
    salary INT NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
);
-- *==============================================================*
-- THE PERSON ENTITIES ARE ABOVE

-- nothing here may be null
CREATE TABLE IF NOT EXISTS EMERGENCY_CONTACT (
    ec_name VARCHAR(20) NOT NULL,
    ec_phone INT NOT NULL,
	ssn INT NOT NULL, -- fk,
	relationship VARCHAR(20) NOT NULL, -- pk
    PRIMARY KEY (relationship),
	FOREIGN KEY (ssn) REFERENCES PERSON (ssn)
);

-- THIS TABLE IS NEW
CREATE TABLE  IF NOT EXISTS ALLERGIES(
    patient_id INT NOT NULL,
	allergy VARCHAR(20) NOT NULL,
    PRIMARY KEY (allergy),
    FOREIGN KEY (patient_id) REFERENCES PATIENT (patient_id)
);

-- MADE SINGULAR
CREATE TABLE IF NOT EXISTS BRANCH (
	branch_num INT NOT NULL, -- pk
	branch_name VARCHAR(20) NOT NULL, -- pk
    street VARCHAR(20) NOT NULL,
    city VARCHAR(20) NOT NULL,
	state VARCHAR(2) NOT NULL,
	phone VARCHAR(10),
	PRIMARY KEY (branch_num),
    UNIQUE (branch_name)
);

CREATE TABLE IF NOT EXISTS DEPARMENT (
	dept_num INT NOT NULL, -- pk
    dept_name VARCHAR(20) NOT NULL,
	PRIMARY KEY (dept_num)
);

 -- added total_working_hours PRIMARY KEY
CREATE TABLE IF NOT EXISTS WORKS_AT (
	shift_hours INT NOT NULL, -- pk
    shift_date DATE NOT NULL, -- pk
	employee_id INT NOT NULL, -- fk
    branch_num INT NOT NULL, -- fk
	-- make this a query hours_ytd INT NOT NULL, -- needs to be calculated value
    PRIMARY KEY (shift_date),
	FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (employee_id),
    FOREIGN KEY (branch_num) REFERENCES BRANCH (branch_num)
);

-- ADDED total_vacation_days_left PRIMARY KEY
CREATE TABLE IF NOT EXISTS PAID_LEAVE (
	employee_id INT NOT NULL, -- fk
	date_used DATE NOT NULL,
    leave_type VARCHAR(8) NOT NULL, -- either sick or vacation
	PRIMARY KEY (date_used),
	FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (employee_id)
);

CREATE TABLE IF NOT EXISTS PATIENT_BILL (
	bill_num INT NOT NULL, -- pk
    bill_date DATE NOT NULL,
    due_date DATE NOT NULL,
    bill_total FLOAT NOT NULL,
    patient_id INT NOT NULL, -- fk
	PRIMARY KEY(bill_num),
    FOREIGN KEY (patient_id) REFERENCES PATIENT (patient_id)
);

CREATE TABLE IF NOT EXISTS APPOINTMENT (
    patient_id INT NOT NULL, -- fk
    employee_id INT NOT NULL, -- fk
    appointment_date DATETIME NOT NULL, -- pk
    service_num INT NOT NULL, -- fk
    branch_num INT NOT NULL, -- fk
    PRIMARY KEY (appointment_date),
    FOREIGN KEY (employee_id) REFERENCES HEALTHCARE_WORKER (employee_id),
    FOREIGN KEY (service_num) REFERENCES SERVICE (s_num),
    FOREIGN KEY (branch_num) REFERENCES BRANCH (branch_num),
    FOREIGN KEY (patient_id) REFERENCES PATIENT (patient_id)
);

-- ADDED 'insur_id' PRIMARY KEY
CREATE TABLE IF NOT EXISTS HEALTH_INSURANCE (
	insur_id INT NOT NULL, -- pk
    insur_name VARCHAR(20) NOT NULL,
    insur_phone VARCHAR(10),
	ssn INT NOT NULL, -- fk
	PRIMARY KEY (insur_id),
	FOREIGN KEY (ssn) REFERENCES PERSON (ssn)
);

CREATE TABLE IF NOT EXISTS MEDICATION (
    med_id INT NOT NULL, -- pk
    med_name VARCHAR(30) NOT NULL,
    dosage VARCHAR(20) NOT NULL, -- pk
    PRIMARY KEY(med_id)
    );

CREATE TABLE IF NOT EXISTS EQUIPMENT (
    asset_id INT NOT NULL, -- pk
    estimated_value INT,
    contract_on_file BOOLEAN NOT NULL,
    employee_id INT NOT NULL, -- fk
    branch_num INT NOT NULL, -- fk
    PRIMARY KEY(asset_id),
    FOREIGN KEY(employee_id) REFERENCES EMPLOYEE (employee_id),
    FOREIGN KEY(branch_num) REFERENCES BRANCH (branch_num)
);

-- CHANGED NAME
CREATE TABLE IF NOT EXISTS FOUR_O_ONE_K_PLAN (
    account_num INT NOT NULL, -- pk
    invest_percentage FLOAT,
    employer_contribution_percentage FLOAT,
    employee_id INT NOT NULL, -- fk
    branch_num INT NOT NULL, -- fk
	PRIMARY KEY (account_num),
    FOREIGN KEY(employee_id) REFERENCES EMPLOYEE (employee_id),
    FOREIGN KEY(branch_num) REFERENCES BRANCH (branch_num)
);

CREATE TABLE IF NOT EXISTS REFERRALS (
    address VARCHAR(20) NOT NULL, -- pk
    phone VARCHAR(10),
    accepted_insurance BOOLEAN,
    practice_name VARCHAR(20),
    patient_id INT NOT NULL, -- fk
    employee_id INT NOT NULL, -- fk
    PRIMARY KEY(address),
    FOREIGN KEY(patient_id) REFERENCES PATIENT (patient_id),
    FOREIGN KEY(employee_id) REFERENCES EMPLOYEE (employee_id)
);

CREATE TABLE IF NOT EXISTS INVENTORY (
	item VARCHAR(10) NOT NULL, -- pk
	stock_qty INT,
    supplier VARCHAR(20),
	branch_num INT NOT NULL, -- fk
	PRIMARY KEY (item),
	FOREIGN KEY (branch_num) REFERENCES BRANCH (branch_num)
);

CREATE TABLE IF NOT EXISTS OFFICE_BILL (
	bill_num INT NOT NULL, -- pk
	branch_num INT NOT NULL, -- fk
	issue_date DATE,
	vendor_name VARCHAR(20),
	due_date DATE,
	bill_total FLOAT,
	PRIMARY KEY (bill_num),
	FOREIGN KEY (branch_num) REFERENCES BRANCH (branch_num)
);

CREATE TABLE IF NOT EXISTS SERVICE (
	s_num INT NOT NULL, -- pk
	s_name VARCHAR(10),
    rate INT NOT NULL, 
	dept_num INT NOT NULL, -- fk
	PRIMARY KEY (s_num),
	FOREIGN KEY (dept_num) REFERENCES DEPARTMENT (dept_num)
);

CREATE TABLE IF NOT EXISTS PERSCRIPTION (
	med_id INT NOT NULL, -- fk
    qty INT NOT NULL,
	refills INT,
    pharmacy_name VARCHAR(20),
    pharmacy_address VARCHAR(40),
    date_sent DATE NOT NULL, -- pk
    employee_id INT NOT NULL, -- fk
	patient_id INT NOT NULL, -- fk
	PRIMARY KEY (date_sent),
    FOREIGN KEY (med_id) REFERENCES MEDICATION (med_id),
    FOREIGN KEY (patient_id) REFERENCES PATIENT (patient_id),
	FOREIGN KEY (employee_id) REFERENCES EMPLOYEE (employee_id)
);

-- enables contraints
SET FOREIGN_KEY_CHECKS = 1;