-- Q1. Who isthe senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2. Which countries have the most Invoices?

SELECT billing_country, COUNT(billing_country) AS t FROM invoice
Group BY billing_country
ORDER BY t DESC
LIMIT 1

-- Q3. What are top 3 values of total invoice?

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

-- Q4. Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals

SELECT billing_city,SUM(total) as t FROM invoice 
GROUP BY billing_city
ORDER BY t DESC
limit 1

-- Q5. 5. Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money

SELECT c.first_name, c.last_name,temp.t
FROM (SELECT customer_id, SUM(total) as t FROM invoice
	GROUP BY customer_id 
	ORDER BY t DESC
	limit 1) AS temp
JOIN customer c
ON temp.customer_id = c.customer_id

----------------------------------------------------------------------------------------

--Q1. Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT email, first_name, last_name
FROM customer 
JOIN invoice  ON customer.customer_id = invoice.customer_id
JOIN invoice_line  ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (SELECT track_id FROM track 
	JOIN genre  
	ON track.genre_id = genre.genre_id
	WHERE genre.name like 'Rock')
ORDER bY email

--Q2. Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands

SELECT a.name,COUNT(a.name) as t
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.name
ORDER BY t DESC
LIMIT 10


--Q3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first

SELECT name FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) as avg_len FROM track)
ORDER BY milliseconds DESC

--------------------------------------------------------------------------------------------------------------
-- Q1.Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

SELECT c.first_Name || ' ' || c.last_Name AS CustomerName,a.name AS ArtistName,
SUM(il.unit_Price * il.quantity) AS TotalSpent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
GROUP BY c.first_name, c.last_Name, a.name
ORDER BY TotalSpent DESC;


--Q2. We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres
WITH popular_genre AS(
SELECT COUNT(il.quantity) AS purchase, i.billing_country AS country, g.name,
ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY COUNT(il.quantity) DESC) AS ranking
FROM invoice_line il
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY 2,3
ORDER BY 2 ASC, 1 DESC)

SELECT country,name AS genre,purchase
FROM popular_genre
WHERE ranking =1

--3. Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount

WITH top_customer AS
(SELECT c.customer_id, c.first_name || c.last_name AS Name, SUM(i.total) AS Total, i.billing_country AS Country,
RANK() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS ranking
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1,4
ORDER BY i.billing_country)

SELECT customer_id, Name , Country ,Total
FROM top_customer
WHERE ranking = 1
