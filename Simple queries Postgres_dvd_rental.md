SELECT customer_id FROM payment
ORDER BY payment_date ASC
LIMIT 10

SELECT DISTINCT customer_id FROM payment ORDER BY payment_date ASC
LIMIT 10

SELECT COUNT(title) FROM film
WHERE length <= 50

SELECT COUNT(*) FROM payment
WHERE amount BETWEEN 8 AND 9;

SELECT * FROM payment
WHERE payment_date BETWEEN '2007-02-01' AND '2007-02-14';
