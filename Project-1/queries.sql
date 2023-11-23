--Question Set#1
/*
- Question 1
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.
*/

/* Query 1.1 - query used for first insight */

SELECT 
    f.title as film_title,
    c.name as category_name,
    r.rental_id
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f
ON f.film_id = fc.film_id
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id

/* Query 1.2 - query that lists each movie ordered by category_name, film_tile */
 SELECT
    f.title as film_title,
    c.name as category_name,
    COUNT(r.rental_id) as rental_count
    FROM category c
    JOIN film_category fq
    ON fq.category_id = c.category_id 
    JOIN film f
    ON f.film_id = fq.film_id
    JOIN inventory i
    ON f.film_id = i.film_id
    JOIN rental r 
    ON r.inventory_id = i.inventory_id
    GROUP BY f.title, c.name
    ORDER BY category_name, film_title

/*
- Question 2
Can you provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories?
*/

/* Query 2.1 - query that lists each film_title, category_name & rental_duration + devides rental_duratioion in quartiles  */
SELECT
    f.title as film_title,
    c.name as category_name,
    f.rental_duration,

    NTILE(4) OVER (PARTITION BY rental_duration ORDER BY rental_duration) AS standard_quartile
FROM category c

JOIN film_category fq
ON fq.category_id = c.category_id 
JOIN film f
ON f.film_id = fq.film_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')

/*
- Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. The resulting table should have three columns:
*/

/* Query 3.1 - query that gets me the relevant data  */
With t1 AS(
       SELECT f.title, c.name as category_name , f.rental_duration, NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
       FROM film_category fc
       JOIN category c
       ON c.category_id = fc.category_id
       JOIN film f
       ON f.film_id = fc.film_id
       WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
)
SELECT 
*
FROM t1


/* Query 3.2 - query that performes the GROUP BY and the ORDER BY */
With t1 AS(
       SELECT f.title, c.name as category_name , f.rental_duration, NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
       FROM film_category fc
       JOIN category c
       ON c.category_id = fc.category_id
       JOIN film f
       ON f.film_id = fc.film_id
       WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
)
SELECT 
t1.category_name,
t1.standard_quartile,
COUNT(*)
FROM t1
GROUP BY t1.standard_quartile, t1.category_name
ORDER BY t1.category_name, t1.standard_quartile

- Question 4 Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month

/* Query 4.1 - query that gets me the necessary data tables */
SELECT 
       DATE_PART('year',r.rental_date) AS rental_year,
       DATE_PART('month',rental_date) AS rental_month,
       s1.store_id,
       r.rental_id
FROM store s1
JOIN staff s2
ON s1.store_id = s2.store_id
JOIN rental r
ON s2.staff_id = r.staff_id

/* Query 4.2 - query that performs the group by and order by */
SELECT 
       DATE_PART('month',rental_date) AS rental_month,
       DATE_PART('year',r.rental_date) AS rental_year,
       s1.store_id,
       COUNT(*) as count_rentals
FROM store s1
JOIN staff s2
ON s1.store_id = s2.store_id
JOIN rental r
ON s2.staff_id = r.staff_id
GROUP BY rental_month,rental_year, s1.store_id
ORDER BY count_rentals DESC, rental_month


/* Question 5
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. 
Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?
*/

/* Query 5.1 - get me top 10 paying customers */
SELECT c.first_name || ' ' || c.last_name AS full_name, SUM(p.amount) as amount_total
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
GROUP BY p.amount, full_name
ORDER BY amount_total DESC
LIMIT 10

/* Query 5.2 - get me the names of these 10 best customers */
SELECT full_name 
FROM (
SELECT c.first_name || ' ' || c.last_name AS full_name, SUM(p.amount) as amount_total
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
GROUP BY p.amount, full_name
ORDER BY amount_total DESC
LIMIT 10
) top_customers

/* Query 5.3 - Get me the relevant data for these top 10  customers */
SELECT 
DATE_TRUNC('month', p.payment_date) as pay_mon,
CONCAT(c.first_name, ' ', c.last_name) as full_name,
p.amount
FROM customer c
JOIN payment p 
ON c.customer_id = p.customer_id
WHERE CONCAT(c.first_name, ' ', c.last_name) IN (
       SELECT full_name 
       FROM (
              SELECT c.first_name || ' ' || c.last_name AS full_name, SUM(p.amount) as amount_total
              FROM customer c
              JOIN payment p
              ON p.customer_id = c.customer_id
              GROUP BY p.amount, full_name
              ORDER BY amount_total DESC
              LIMIT 10
              ) top_customers
              )

/* Query 5.4 - Perform the relevant GROUP BY AND ORDER BY and filter to 2007 */

SELECT DATE_TRUNC('month', p.payment_date) pay_month, 
c.first_name || ' ' || c.last_name AS full_name, 
COUNT(p.amount) AS pay_countpermon, 
SUM(p.amount) AS pay_amount
FROM customer c
JOIN payment p
ON p.customer_id = c.customer_id
WHERE c.first_name || ' ' || c.last_name IN
       (SELECT t1.full_name
       FROM
              (SELECT c.first_name || ' ' || c.last_name AS full_name, SUM(p.amount) as amount_total
              FROM customer c
              JOIN payment p
              ON p.customer_id = c.customer_id
              GROUP BY 1	
              ORDER BY 2 DESC
              LIMIT 10) t1) AND (p.payment_date BETWEEN '2007-01-01' AND '2008-01-01')
GROUP BY full_name, pay_month
ORDER BY full_name, pay_month, pay_countpermon


--Question 6
--Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly payments during 2007. 
--Please go ahead and write a query to compare the payment amounts in each successive month. Repeat this for each of these 10 paying customers. 
--Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments.

/* Query 6.1 - Table in order for preparation to get top 10 paying  customers*/
SELECT first_name || ' ' || last_name AS full_name, 
c.customer_id, 
p.amount, 
p.payment_date
FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id

/* Query 6.2 - Get top 10 paying customers*/
SELECT t1.customer_id
       FROM ( 
              SELECT
              c.first_name || ' ' || c.last_name AS full_name, 
              c.customer_id, 
              p.amount, 
              p.payment_date
              FROM customer AS c
              JOIN payment AS p
              ON c.customer_id = p.customer_id
              ) t1
       GROUP BY t1.customer_id
       ORDER BY SUM(t1.amount) DESC
       LIMIT 10


/* Query 6.3 - Put everything together*/
WITH t1 AS (SELECT (first_name || ' ' || last_name) AS full_name, 
                   c.customer_id, 
                   p.amount, 
                   p.payment_date
              FROM customer AS c
                   JOIN payment AS p
                    ON c.customer_id = p.customer_id),

     t2 AS (SELECT t1.customer_id
              FROM t1
             GROUP BY 1
             ORDER BY SUM(t1.amount) DESC
             LIMIT 10),

       t3 AS (SELECT t1.full_name,
              DATE_PART('month', t1.payment_date) AS payment_month, 
              DATE_PART('year', t1.payment_date) AS payment_year,
              COUNT (*),
              SUM(t1.amount),
              SUM(t1.amount) AS total_amount,
              LEAD(SUM(t1.amount)) OVER(PARTITION BY t1.full_name ORDER BY DATE_PART('month', t1.payment_date)) AS lead,
              LEAD(SUM(t1.amount)) OVER(PARTITION BY t1.full_name ORDER BY DATE_PART('month', t1.payment_date)) - SUM(t1.amount) AS lead_dif
         FROM t1
              JOIN t2
               ON t1.customer_id = t2.customer_id
        WHERE t1.payment_date BETWEEN '20070101' AND '20080101'
        GROUP BY 1, 2, 3
        ORDER BY 1, 3, 2)

SELECT t3.*,
       CASE
           WHEN t3.lead_dif = (SELECT MAX(t3.lead_dif) FROM t3 ORDER BY 1 DESC LIMIT 1) THEN '1'
           ELSE NULL
           END AS is_max					
  FROM t3
 ORDER BY 1;