# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project(https://github.com/narpatganwliya7/Library-System-Management.git)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/narpatganwliya7/Library-System-Management.git)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
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


```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_name = 'Rakesh Karwasara'
WHERE member_id = 'C101'
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS137';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E107'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_count
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT
	e1.* ,
	br.manager_id,
	e2.emp_name as manager

FROM employees AS e1
JOIN branch AS br
	ON br.branch_id = e1.branch_id
JOIN employees AS e2
	ON e2.emp_id = br.manager_id

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
	m.member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS Overdue
FROM issued_status AS ist
JOIN members AS m
ON ist.issued_member_id = m.member_id

JOIN books AS b
ON ist.issued_book_isbn = b.isbn

LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_Date IS NULL
AND (CURRENT_DATE - ist.issued_date) >30
ORDER BY 1
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

SELECT * FROM issued_status
WHERE isbn ='978-0-375-41398-8'

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

SELECT * FROM return_status
WHERE issued_id = 'IS134'

INSERT INTO return_status(return_id, issued_id,return_date)
VALUES
('RS119', 'IS134', CURRENT_DATE)

UPDATE books 
SET status = 'yes'
WHERE isbn = '978-0-375-41398-8'

SELECT * FROM return_status
WHERE issued_id = 'IS134'


-- Store Procedure 
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), 
												p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(55);
	v_book_name VARCHAR(80);
BEGIN 
	
	SELECT ist.issued_book_isbn,
		   b.book_title
		  INTO v_isbn, --v = variable 
		  	   v_book_name
	FROM issued_status AS ist
	JOIN books AS b	
		 ON b.isbn = ist.issued_book_isbn
	WHERE issued_id = p_issued_id;

	INSERT INTO return_status(return_id, issued_id,return_book_name,return_date, return_book_isbn)
	VALUES
	(p_return_id,p_issued_id,v_book_name,CURRENT_DATE,v_isbn);

	
	UPDATE books 
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %',v_book_name;

END;
$$

-- For calling above prodecure
-- call add_return_records();
-- example 1

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1'

SELECT * FROM issued_status
WHERE isbn = '978-0-307-58837-1'

SELECT * FROM return_status
WHERE issued_id = 'IS135'

call add_return_records('RS120', 'IS135')

-- example 2

SELECT * FROM issued_status
	WHERE isbn = '978-0-330-25864-8' AND issued_id = 'IS140'
	
SELECT * FROM books
	WHERE isbn = '978-0-330-25864-8'

SELECT * FROM return_status 
	WHERE issued_id = 'IS140'

CALL add_return_records ('RS121', 'IS140')

--## Converting status to NO from YES

CREATE OR REPLACE PROCEDURE add_issued_records(p_issued_id VARCHAR(10), p_member_id VARCHAR(10),p_isbn VARCHAR(55), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
		
            v_book_name VARCHAR(55);
BEGIN
	
	SELECT issued_book_name
		
	INTO v_book_name
		
	FROM issued_status;

	INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn,issued_emp_id)
	VALUES (p_issued_id, p_member_id, v_book_name, CURRENT_DATE, p_isbn, p_issued_emp_id);


	UPDATE books
	SET status = 'no'
	WHERE isbn = p_isbn;

	RAISE NOTICE 'The book: % has been issued to member: %', v_book_name, p_member_id;

END;
$$


-- Example
SELECT * FROM return_status

SELECT * FROM issued_status
WHERE issued_id = 'IS111'

SELECT * FROM books
WHERE isbn = '978-0-679-76489-8'


call add_issued_records ('IS141', 'C107', '978-0-679-76489-8', 'E108' )

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT 
	  e.emp_id,
	  e.emp_name,
	  COUNT (ist.issued_id) AS Processed_books,
	  e.branch_id
FROM employees AS e
JOIN issued_status AS ist
ON ist.issued_emp_id = e.emp_id
GROUP BY 1
ORDER BY processed_books DESC
LIMIT 3
```


**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

SELECT * FROM books;
SELECT * FROM issued_status;

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(30),p_isbn VARCHAR(55),p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	-- all the variable
	v_status VARCHAR (10);
	v_book_name VARCHAR (55);
BEGIN
	-- all the codes
		-- checking if book is available 'yes'
	SELECT status,
		   book_title
			INTO v_status,
				 v_book_name
	FROM books
	WHERE isbn= p_isbn;

	IF v_status = 'yes'
	THEN
		INSERT INTO issued_status(issued_id,issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
		VALUES
				(p_issued_id, p_issued_member_id, v_book_name, CURRENT_DATE, p_isbn, p_issued_emp_id);

		UPDATE books
		SET status ='No'
		WHERE isbn = p_isbn;

		RAISE NOTICE 'The book is sucessfully issued to the memeber: %', p_issued_member_id;
		
		ELSE
			RAISE NOTICE 'Unfortunatily, this book: % is not available right now.', p_isbn;

		END IF;
END;
$$


-- example

SELECT * FROM issued_status as i
join books as b
on i.issued_book_isbn = b.isbn
SELECT * FROM books

call issue_book('IS141', 'C107', '978-0-330-25864-8','E106' )
	
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   (https://github.com/narpatganwliya7/Library-System-Management.git)
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Narpat Ganwliya

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:

- **Instagram**: [Follow me for daily tips and updates](https://www.instagram.com/narpat_choudhary1?igsh=MXYzN3l4YjRneTFlNA==)
- **LinkedIn**: [Connect with me professionally](www.linkedin.com/in/narpat-ganwliya)
- **Email**:    narpatganwliya678@gmail.com


Thank you!
