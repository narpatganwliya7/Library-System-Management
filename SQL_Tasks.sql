-- Verifying all the tables
SELECT * FROM books;
SELECT * FROM branch;
SELECT* FROM members;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Project Tasks

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_name = 'Rakesh Karwasara'
WHERE member_id = 'C101'

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS137' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS137'

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E107'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT
	issued_emp_id
	-- COUNT(issued_id) AS total_books_issued  
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT (issued_id) > 1

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_count

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

-- Data Analysis
-- Task 7. Retrieve All Books in a Specific Category: 'Classic'
SELECT * FROM books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:
SELECT
	b.category,
	SUM(b.rental_price) AS Total_Rental_Income,
	COUNT(*) AS no_of_books
FROM books AS b
JOIN issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1

-- Task 9: List Members Who Registered in the Last 180 Days
SELECT *
	FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 DAYS'
	
-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT
	e1.* ,
	br.manager_id,
	e2.emp_name as manager

FROM employees AS e1
JOIN branch AS br
	ON br.branch_id = e1.branch_id
JOIN employees AS e2
	ON e2.emp_id = br.manager_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold: $7
CREATE TABLE Expensive_books
AS
SELECT * FROM books
WHERE rental_price > 7

-- Task 12: Retrieve the List of Books Not Yet Returned	
SELECT * 
FROM issued_status AS ist
LEFT JOIN return_status as rs
	ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period).
-- Display the member's_id, member's name, book title, issue date, and days overdue.

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

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books 
-- table to "Yes" when they are returned (based on entries in the return_status table).

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
	
	SELECT ist.isbn,
		   b.book_title
		  INTO v_isbn, --v = variable 
		  	   v_book_name
	FROM issued_status AS ist
	JOIN books AS b	
		 ON b.isbn = ist.isbn
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

	INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, isbn,issued_emp_id)
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


--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE branch_report
AS
SELECT 
	  br.branch_id,
	  SUM(b.rental_price) AS Total_revenue,
	  COUNT (ist.issued_id) AS Total_books_issued,
	  COUNT (rs.return_id) AS Total_return_books
	  
FROM issued_status AS ist
JOIN 
	employees AS e
ON e.emp_id = issued_emp_id
JOIN
	branch AS br
ON br.branch_id = e.branch_id
LEFT JOIN 
	return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN 
	books AS b
ON b.isbn = ist.isbn
GROUP BY 1

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 2 months.

DROP TABLE IF EXISTS Active_members;
CREATE TABLE Active_members
AS
SELECT * FROM members
WHERE member_id IN 
				( SELECT issued_member_id
				FROM issued_status
				WHERE issued_date > CURRENT_DATE - INTERVAL '2 months')

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the
-- most book issues. Display the employee name, number of books processed, and their branch.

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

/* Task 19: Stored Procedure Objective: Create a stored procedure to
manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book 
in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the 
books table should be updated to 'no'. If the book is not available
(status = 'no'), the procedure should return an error message indicating
that the book is currently not available.
*/

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
		INSERT INTO issued_status(issued_id,issued_member_id, issued_book_name, issued_date, isbn, issued_emp_id)
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
on i.isbn = b.isbn
SELECT * FROM books

call issue_book('IS141', 'C107', '978-0-330-25864-8','E106' )
	