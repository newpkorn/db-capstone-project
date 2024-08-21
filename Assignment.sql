
/*
Task 2
For your second task, Little Lemon need information from four tables on all customers with orders that cost more than $150. Extract the required information from each of the following tables by using the relevant JOIN clause: 

Customers table: The customer id and full name.

Orders table: The order id and cost.

Menus table: The menus name.

MenusItems table: course name and starter name.

The result set should be sorted by the lowest cost amount.
*/

USE LittleLemonDB;

SELECT 
    o.OrderID,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    o.OrderID,
    o.TotalCost AS Cost,
    m.Course AS MenuName,
    mi.CourseName
FROM Orders o
JOIN Customer_Details c ON o.CustomerID = c.CustomerID
JOIN Menus m ON o.MenuID = m.MenuID
JOIN MenuItems mi ON m.MenuItemsID = mi.MenuItemsID
WHERE o.TotalCost > 150
ORDER BY o.TotalCost ASC;

/*
Task 3
For the third and final task, Little Lemon need you to find all menu items for which more than 2 orders have been placed. You can carry out this task by creating a subquery that lists the menu names from the menus table for any order quantity with more than 2.

Here’s some guidance around completing this task: 

Use the ANY operator in a subquery

The outer query should be used to select the menu name from the menus table.

The inner query should check if any item quantity in the order table is more than 2. 

The output result of your query (depends on the data populated in your database) should be similar to the following screenshot:
*/

SELECT m.Cuisine AS MenuName
FROM Menus m
WHERE m.MenuID = ANY (
    SELECT o.MenuID
    FROM Orders o
    WHERE o.Quantity > 2
    GROUP BY o.MenuID
    HAVING COUNT(o.OrderID) > 2
);

-- Exercise: Create optimized queries to manage and analyze data
/*
Task 1
In this first task, Little Lemon need you to create a procedure that displays the maximum ordered quantity in the Orders table. 

Creating this procedure will allow Little Lemon to reuse the logic implemented in the procedure easily without retyping the same code over again and again to check the maximum quantity. 

You can call the procedure GetMaxQuantity and invoke it as follows:

CALL GetMaxQuantity();
*/

DELIMITER //

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS `MAX Quantity in Order`
    FROM Orders;
END //

DELIMITER ;

/*
Task 2
In the second task, Little Lemon need you to help them to create a prepared statement called GetOrderDetail. This prepared statement will help to reduce the parsing time of queries. It will also help to secure the database from SQL injections.

The prepared statement should accept one input argument, the CustomerID value, from a variable. 

The statement should return the order id, the quantity and the order cost from the Orders table. 

Once you create the prepared statement, you can create a variable called id and assign it value of 1. 

Then execute the GetOrderDetail prepared statement using the following syntax:

SET @id = 1;
EXECUTE GetOrderDetail USING @id;
*/

-- Define the prepared statement
PREPARE GetOrderDetail FROM 
'SELECT OrderID, Quantity, TotalCost
 FROM Orders
 WHERE CustomerID = ?';
-- Create a variable and assign a value
SET @id = 1;

-- Execute the prepared statement using the variable
EXECUTE GetOrderDetail USING @id;
-- Deallocate the prepared statement
DEALLOCATE PREPARE GetOrderDetail;

/*
Task 3
Your third and final task is to create a stored procedure called CancelOrder. Little Lemon want to use this stored procedure to delete an order record based on the user input of the order id.

Creating this procedure will allow Little Lemon to cancel any order by specifying the order id value in the procedure parameter without typing the entire SQL delete statement.   

If you invoke the CancelOrder procedure, the output result should be similar to the output of the following screenshot:

call CancelOrder(5);

Confirmation
Order 5 is canceled
*/

-- Step 1: Define the Stored Procedure
DELIMITER //

CREATE PROCEDURE CancelOrder(IN orderID INT)
BEGIN
    -- Delete the order record from the Orders table
    DELETE FROM Orders
    WHERE OrderID = orderID;
    
    -- Output confirmation message
    SELECT CONCAT('Order ', orderID, ' is canceled') AS Confirmation;
END //

DELIMITER ;

-- Step 2: Call the Stored Procedure
CALL CancelOrder(5);


-- Exercise: Create SQL queries to check available bookings based on user input
/*
Task 1
Little Lemon wants to populate the Bookings table of their database with some records of data. Your first task is to replicate the list of records in the following table by adding them to the Little Lemon booking table. 

You can use simple INSERT statements to complete this task.
BookingID BookingDate TableNumber CustomerID
1         2022-10-10  5           1
2         2022-11-12  3           3
3         2022-10-11  2           2
4         2022-10-13  2           1
*/

-- Insert records into the Bookings table
INSERT INTO Bookings (BookingDate, TableNo, CustomerID)
VALUES
('2022-10-10', 5, 1),
('2022-11-12', 3, 3),
('2022-10-11', 2, 2),
('2022-10-13', 2, 1);

select * from Bookings;

/*
Task 2
For your second task, Little Lemon need you to create a stored procedure called CheckBooking to check whether a table in the restaurant is already booked. Creating this procedure helps to minimize the effort involved in repeatedly coding the same SQL statements.

The procedure should have two input parameters in the form of booking date and table number. You can also create a variable in the procedure to check the status of each table.

The output of your procedure should be similar to the following screenshot:

call CheckBooking("2022-11-12", 3);

Booking status
Table 3 is already booked
*/

-- 1. Create the Stored Procedure
DELIMITER //

CREATE PROCEDURE CheckBooking(
    IN bookingDate DATE,
    IN tableNumber INT
)
BEGIN
    DECLARE bookingStatus VARCHAR(255);

    -- Check if there is any booking for the given date and table number
    IF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingDate = bookingDate
        AND TableNo = tableNumber
    ) THEN
        SET bookingStatus = CONCAT('Table ', tableNumber, ' is already booked');
    ELSE
        SET bookingStatus = CONCAT('Table ', tableNumber, ' is available');
    END IF;

    -- Select the status to return it as the result
    SELECT bookingStatus AS 'Booking status';
END //

DELIMITER ;

-- Call the Stored Procedure
CALL CheckBooking('2022-11-12', 3);


/*
Task 3
For your third and final task, Little Lemon need to verify a booking, and decline any reservations for tables that are already booked under another name. 

Since integrity is not optional, Little Lemon need to ensure that every booking attempt includes these verification and decline steps. However, implementing these steps requires a stored procedure and a transaction. 

To implement these steps, you need to create a new procedure called AddValidBooking. This procedure must use a transaction statement to perform a rollback if a customer reserves a table that’s already booked under another name.  

Use the following guidelines to complete this task:

The procedure should include two input parameters in the form of booking date and table number.

It also requires at least one variable and should begin with a START TRANSACTION statement.

Your INSERT statement must add a new booking record using the input parameter's values.

Use an IF ELSE statement to check if a table is already booked on the given date. 

If the table is already booked, then rollback the transaction. If the table is available, then commit the transaction. 

The screenshot below is an example of a rollback (cancelled booking), which was enacted because table number 5 is already booked on the specified date.

CALL AddValidBooking("2022-12-17", 6);

Booking status
Table 6 is already booked - cancelled
*/
-- 1. Create the Stored Procedure
DELIMITER //

CREATE PROCEDURE AddValidBooking(
    IN bookingDate DATE,
    IN tableNumber INT,
    IN customerID INT
)
BEGIN
    DECLARE existingBooking INT;

    -- Start the transaction
    START TRANSACTION;

    -- Check if the table is already booked on the specified date
    SELECT COUNT(*) INTO existingBooking
    FROM Bookings
    WHERE BookingDate = bookingDate
    AND TableNo = tableNumber;

    IF existingBooking > 0 THEN
        -- If the table is already booked, rollback the transaction
        ROLLBACK;
        SELECT CONCAT('Table ', tableNumber, ' is already booked - cancelled') AS 'Booking status';
    ELSE
        -- If the table is available, insert the new booking and commit the transaction
        INSERT INTO Bookings (BookingDate, TableNo, CustomerID)
        VALUES (bookingDate, tableNumber, customerID);

        COMMIT;
        SELECT CONCAT('Booking for table ', tableNumber, ' on ', bookingDate, ' has been confirmed') AS 'Booking status';
    END IF;
END //

DELIMITER ;


-- 2. Call the Stored Procedure
CALL AddValidBooking('2022-12-17', 6, 1);


-- Exercise: Create SQL queries to add and update bookings
/*
Task 1
In this first task you need to create a new procedure called AddBooking to add a new table booking record.

The procedure should include four input parameters in the form of the following bookings parameters:

booking id, 

customer id, 

booking date,

and table number.

The screenshot below shows an example of the AddBooking statement:

CALL AddBooking(9, 3, 4 "2022-12-30");

Confirmation
New booking added
*/

-- 1, Define the Procedure: The procedure should accept four parameters: BookingID, CustomerID, BookingDate, and TableNo.
-- 2.Insert the Data: Use the parameters to insert a new record into the Bookings table.
DELIMITER //

CREATE PROCEDURE AddBooking(
    IN bookingID INT,
    IN customerID INT,
    IN bookingDate DATE,
    IN tableNo INT
)
BEGIN
    -- Insert a new booking record into the Bookings table
    INSERT INTO Bookings (BookingID, BookingDate, TableNo, CustomerID)
    VALUES (bookingID, bookingDate, tableNo, customerID);

    -- Confirm that the booking has been added
    SELECT 'New booking added' AS Confirmation;
END //

DELIMITER ;

-- 3. Calling the Procedure
CALL AddBooking(9, 3, '2022-12-30', 4);

/*
Task 2
For your second task, Little Lemon need you to create a new procedure called UpdateBooking that they can use to update existing bookings in the booking table.

The procedure should have two input parameters in the form of booking id and booking date. You must also include an UPDATE statement inside the procedure. 

The screenshot below shows an example of the UpdateBooking procedure in use.

CALL UpdateBooking(9, "2022-12-17");

Confirmation
Booking 9 updated
*/

-- 1. Define the Procedure: The procedure should accept two parameters: BookingID and BookingDate.
-- 2. Update the Data: Use the parameters to update the BookingDate for the specified BookingID.
DELIMITER //

CREATE PROCEDURE UpdateBooking(
    IN bookingID INT,
    IN newBookingDate DATE
)
BEGIN
    -- Update the booking date for the specified booking ID
    UPDATE Bookings
    SET BookingDate = newBookingDate
    WHERE BookingID = bookingID;

    -- Confirm that the booking has been updated
    SELECT CONCAT('Booking ', bookingID, ' updated') AS Confirmation;
END //

DELIMITER ;

-- 3. Calling the Procedure
CALL UpdateBooking(9, '2022-12-17');

/*
Task 3
For the third and final task, Little Lemon need you to create a new procedure called CancelBooking that they can use to cancel or remove a booking.

The procedure should have one input parameter in the form of booking id. You must also write a DELETE statement inside the procedure. 

When the procedure is invoked, the output result should be similar to the following screenshot:

CALL CancelBooking(9);

Confirmation
Booking 9 cancelled
*/

-- 1. Create the Procedure: Define the procedure to accept a bookingID parameter and perform a DELETE operation on the Bookings table. Ensure that the procedure outputs a confirmation message.
DELIMITER //

CREATE PROCEDURE CancelBooking(
    IN bookingID INT
)
BEGIN
    -- Delete the booking with the specified BookingID
    DELETE FROM Bookings
    WHERE BookingID = bookingID;

    -- Confirm that the booking has been cancelled
    SELECT CONCAT('Booking ', bookingID, ' cancelled') AS Confirmation;
END //

DELIMITER ;

-- 2. Call the Procedure
CALL CancelBooking(11);

-- Create ManageBooking() Procedure
DELIMITER //

CREATE PROCEDURE ManageBooking(
    IN p_BookingDate DATE,
    IN p_TableNo INT,
    IN p_CustomerID INT,
    IN p_StaffID INT
)
BEGIN
    INSERT INTO Bookings (BookingDate, TableNo, CustomerID, StaffID)
    VALUES (p_BookingDate, p_TableNo, p_CustomerID, p_StaffID);
END //

DELIMITER ;

CALL ManageBooking('2024-08-23', 10, 1, 4);


-- Create UpdateBooking() Procedure
DELIMITER //

CREATE PROCEDURE UpdateBooking(
    IN p_BookingID INT,
    IN p_BookingDate DATE,
    IN p_TableNo INT,
    IN p_CustomerID INT,
    IN p_StaffID INT
)
BEGIN
    UPDATE Bookings
    SET BookingDate = p_BookingDate,
        TableNo = p_TableNo,
        CustomerID = p_CustomerID,
        StaffID = p_StaffID
    WHERE BookingID = p_BookingID;
END //

DELIMITER ;

CALL UpdateBooking(12, '2024-08-24', 5, 3, 5);




