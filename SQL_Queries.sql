-- Library Mangement Project 2

-- Creating Tables

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
					(branch_id VARCHAR(15) PRIMARY KEY,
					manager_id VARCHAR(15),
					branch_address VARCHAR(55),
					contact_no VARCHAR(15)
					)
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
					(emp_id VARCHAR(20) PRIMARY KEY,
					emp_name VARCHAR(30),
					position VARCHAR(15),
					salary INT,
					branch_id VARCHAR(20) --FK
					)
DROP TABLE IF EXISTS books;
CREATE TABLE books
					(isbn VARCHAR(50) PRIMARY KEY,
					book_title VARCHAR(100),
					category VARCHAR(50),
					rental_price FLOAT,
					status VARCHAR(50),
					author VARCHAR(50),
					publisher VARCHAR(50)
					)
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
					(issued_id VARCHAR(15) PRIMARY KEY,
					issued_member_id VARCHAR(15), -- FK
					issued_book_name VARCHAR(100),
					issued_date DATE(30),
					issued_book_isbn VARCHAR(25), -- FK
					issued_emp_id VARCHAR(15) --FK
					)
DROP TABLE IF EXISTS members;
CREATE TABLE members
					(member_id VARCHAR(15) PRIMARY KEY,
					member_name VARCHAR(25),
					member_address VARCHAR(50),
					reg_date DATE(25)
					)
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status 
					(return_id VARCHAR(20) PRIMARY KEY,
					issued_id VARCHAR(20),
					return_book_name VARCHAR(55),	
					return_date DATE(30),
					return_book_isbn VARCHAR(55)
					)

-- Foreign Key
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_return_issued
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


