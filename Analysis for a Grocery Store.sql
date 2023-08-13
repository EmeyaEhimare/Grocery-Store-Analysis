create database if not exists grocerystore;

use grocerystore;

-- Select customer name together with each order the customer made
SELECT 
    CustomerID, CustomerName, OrderId, ProductID, ProductName
FROM
    customers
        JOIN
    orders USING (customerid)
        JOIN
    `order details` USING (orderid)
        JOIN
    products USING (productid)
ORDER BY customerid;



-- Select order id together with name of employee who handled the order.
SELECT 
    OrderID,
    EmployeeID,
    CONCAT(firstname, '', lastname) AS 'Full Name'
FROM
    orders
        JOIN
    employees USING (employeeid);
 
 

-- Select customers who did not placed any order yet
SELECT 
    c.CustomerId, c.CustomerName, o.orderid
FROM
    customers c
        LEFT JOIN
    orders o USING (customerid)
WHERE
    o.orderid IS NULL;



-- Select order id together with the name of products.
SELECT 
    OrderID, ProductName
FROM
    grocerystore.`order details`
        JOIN
    products USING (productid);



--  Select products that no one bought.
SELECT 
    *
FROM
    grocerystore.`order details`
        LEFT JOIN
    products USING (productid);
-- where orderid is null



SELECT 
    CustomerId, CustomerName, ProductName
FROM
    customers
        JOIN
    orders USING (customerid)
        JOIN
    `order details` USING (orderid)
        JOIN
    products USING (productid);




-- Select product names together with the name of corresponding category.
SELECT 
    ProductName, CategoryID
FROM
    products;


-- . Select orders together with the name of the shipping company.
SELECT 
    OrderID, ShipperName
FROM
    orders
        JOIN
    shippers USING (shipperid);



-- Select customers with id greater than 50 together with each order they made
SELECT 
    CustomerID, OrderID, ProductID, ProductName
FROM
    customers
        JOIN
    orders USING (customerid)
        JOIN
    `order details` USING (orderid)
        JOIN
    products USING (productid)
WHERE
    customerid > 50
ORDER BY customerid;



--  Select employees together with orders with order id greater than 10400
SELECT 
    EmployeeId, OrderID
FROM
    employees
        JOIN
    orders USING (employeeid)
WHERE
    OrderId > 10400;



--  Select the most expensive product.

select ranking,ProductName, Price
from
(
SELECT productname, 
       price,
       RANK() OVER (ORDER BY price desc) AS ranking
FROM products
)sub
where ranking= 1;




-- Select the second most expensive product.
select ranking, ProductName,Price
from
(
select productname, price,
rank() over(order by price desc) as ranking
from products
)sub
where ranking = 2;




-- Select name and price of each product, sort the result by price in decreasing order
SELECT 
    ProductName, Price
FROM
    products
ORDER BY price DESC;




-- Select 5 most expensive products. 
select ranking, ProductName, Price
from
(
select  ProductName, price,
rank() over(order by price desc) as ranking
from products    
) sub
where ranking <= 5;




-- Select 5 most expensive products without the most expensive (in final 4 products)
select ranks,productname,price
from
(
select ProductName,
	   Price,
rank() over(order by price desc) as ranks
from products  
)sub
where ranks between 2 and 5;




-- Select name of the cheapest product (only name) without using LIMIT and OFFSET.
select ranks, price
from
(
select ProductName,
	   Price,
rank() over(order by price ) as ranks
from products  
)sub
where ranks = 1;



--  Select name of the cheapest product (only name) using subquery
select productname
from
(
select ProductName,
	   Price,
rank() over(order by price ) as ranks
from products  
)sub
where ranks = 1;




-- Select number of employees with LastName that starts with 'D'
SELECT 
    *
FROM
    employees
WHERE
    LastName LIKE 'D%';



-- Select customer name together with the number of orders made by the corresponding customer, sort the result by number of orders in decreasing order.
SELECT 
    CustomerName, COUNT(orderid) AS 'Number Of Orders'
FROM
    customers
        LEFT JOIN
    orders USING (customerid)
GROUP BY 1
ORDER BY 2 DESC;



--  Add up the price of all products
SELECT 
    SUM(price) AS 'Total Price Of Products'
FROM
    products;



--  Select orderID together with the total price of that Order, order the result by total price of order in increasing order.
SELECT 
    OrderID, ROUND(SUM(price), 2) AS 'Total Price Of Order'
FROM
    `order details`
        LEFT JOIN
    products USING (productid)
GROUP BY 1
ORDER BY 2;





--  Select customer who spend the most money.
SELECT 
    CustomerName, ROUND(SUM(price), 2) AS 'Total Money Spent'
FROM
    customers
        LEFT JOIN
    orders USING (customerid)
        LEFT JOIN
    `order details` USING (orderid)
        LEFT JOIN
    products USING (productid)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;



--  Select customer who spend the most money and lives in Canada
select customername, Total_Money_Spent 
from 
(
select customername, Total_Money_Spent,
rank() over(order by Total_Money_Spent desc) as ranking
from
(
SELECT 
    customername, ROUND(SUM(price), 2) AS Total_Money_Spent
FROM
    (SELECT 
        *
    FROM
        customers c
    LEFT JOIN orders o USING (customerid)
    LEFT JOIN `order details` od USING (orderid)
    LEFT JOIN products p USING (productid)
    WHERE
        country LIKE '%Canada%') sub
GROUP BY 1
ORDER BY 2 DESC
)sub
)sub1
where ranking = 1;


--  Select customer who spend the second most money.
select ranking, customername, Total_Money_Spent
from(
select customername, Total_Money_Spent,
 rank() over(order by Total_Money_Spent desc ) as ranking
 from
 (
select CustomerName,
       round(sum(price),2) as Total_Money_Spent
from customers
left join orders
using(customerid)
left join `order details`
using(orderid)
left join products
using(productid)
group by 1
order by 2 desc

)sub1
)sub2
where ranking = 2;




--  Select shipper together with the total price of proceed orders.
SELECT 
    ShipperName,
    ROUND(SUM(price), 2) AS 'total price of proceed orders'
FROM
    shippers
        JOIN
    orders USING (shipperid)
        JOIN
    `order details` USING (orderid)
        JOIN
    products USING (productid)
GROUP BY 1
ORDER BY 2 DESC;



-- Most use Supplier

select supplierid, max(number_of_suppliers) as number_of_products_supplied
from
(
select suppliername,
	   supplierid,
       productid,
       row_number() over (partition by supplierid order by supplierid) as number_of_suppliers
from suppliers
join products using(supplierid)
)sub
group by 1;




-- . Most use Shipper
SELECT 
    shipperid,
    COUNT(orderid) AS 'Number Of Times Shipper Was Used'
FROM
    shippers
        JOIN
    orders USING (shipperid)
GROUP BY 1
ORDER BY 2;

select ranking,employeeid, Number_Of_Orders_Handled
from
(
select employeeid, Number_Of_Orders_Handled,
       rank() over (order by Number_Of_Orders_Handled desc) as ranking
from(
select employeeid,
       count(orderid) as Number_Of_Orders_Handled
from employees
join orders using(employeeid)
group by 1
)sub
)sub1
where ranking = 1;


select employeeid, Number_Of_Orders_Handled,
       rank() over (order by Number_Of_Orders_Handled desc) as ranking
from(
select employeeid,
       count(orderid) as Number_Of_Orders_Handled
from employees
join orders using(employeeid)
group by 1
)sub;




-- Buyers who have Transacted more than two times
select customerid,customername,number_of_orders_made
from
(
select customerid, customername, orderid,
row_number() over(partition by customerid) as number_of_orders_made
from customers
join orders using(customerid)
)sub
where number_of_orders_made > 2;





SELECT 
    EXTRACT(MONTH FROM orderdate) AS Months
FROM
    orders;


SELECT 
    EXTRACT(MONTH FROM orderdate) AS Months,
    ROUND(SUM(price), 2) AS Total_Amount
FROM
    orders
        JOIN
    `order details` USING (orderid)
        JOIN
    products USING (productid)
GROUP BY 1;



--  Top 5 best-selling products.
select productid, Number_Of_Orders, ranking
from
(
select productid,Number_Of_Orders,
       dense_rank() over(order by Number_Of_Orders desc) as ranking
from
(       
select productid,
       count(orderid) as Number_Of_Orders
from products
join `order details` using(productid)
group by 1
order by 2 desc
)sub
)sub1
where ranking between 1 and 5;

SELECT 
    productid, COUNT(orderid) AS Number_Of_Orders
FROM
    products
        JOIN
    `order details` USING (productid)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;




-- Who are the Top 5 customers with the highest purchase value?
SELECT 
    CustomerName,
    ROUND(SUM(price * quantity), 2) AS 'Purchase Value'
FROM
    products
        JOIN
    `order details` USING (productid)
        JOIN
    orders USING (orderid)
        JOIN
    customers USING (customerid)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;



-- Total Revenue.
SELECT 
    ROUND(SUM(quantity * price), 2) AS 'Total Revenue'
FROM
    products
        JOIN
    `order details` USING (productid)
        JOIN
    orders USING (orderid)
        JOIN
    customers USING (customerid);




-- Total number of products sold so far.
SELECT 
    SUM(quantity) AS 'Total Number Of Products Sold'
FROM
    products
        JOIN
    `order details` USING (productid);





-- 
SELECT 
    categoryid,
    COUNT(productid) AS 'Number Of Products In Each Category'
FROM
    products
GROUP BY 1
ORDER BY 2 DESC;


-- Revenue By Year
select extract(year from OrderDate) as year,
round(SUM(quantity * price),2) as 'revenue'
from
(
SELECT *
FROM
    products
        JOIN
    `order details` as od USING (productid)
        JOIN
    orders o USING (orderid)
        JOIN
    customers c USING (customerid)
    )sub
    group by 1;



