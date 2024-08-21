
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



