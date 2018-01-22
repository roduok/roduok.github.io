-- 1a
USE sakila;
SELECT first_name, last_name
FROM actor;

-- 1b
USE sakila;
SELECT CONCAT(a.first_name, ' ', a.last_name) AS Actor_Name
FROM actor a;

-- 2a
USE sakila;
SELECT a.actor_id, a.first_name, a.last_name 
FROM actor a
WHERE a.first_name = "Joe";

-- 2b
USE sakila;
SELECT a.first_name, a.last_name 
FROM actor a
WHERE a.last_name LIKE "%GEN%";

-- 2c
USE sakila;
SELECT a.first_name, a.last_name 
FROM actor a
WHERE a.last_name LIKE "%LI%"
ORDER BY a.last_name, a.first_name ASC;

-- 2d
USE sakila;
SELECT c.country_id, c.country 
FROM country c
WHERE c.country in("Afghanistan", "Bangladesh", "China");

-- 3a
USE sakila;
alter table actor 
add column middle_name VARCHAR(255) AFTER first_name;

-- 3b
USE sakila;
alter table actor 
drop column middle_name;

alter table actor
add column middle_name BLOB AFTER first_name;

-- 3c

USE sakila;
SELECT * FROM actor;
alter table actor 
drop column middle_name;

-- 4a
USE sakila;
SELECT last_name, count(*) as NUM 
FROM actor GROUP BY last_name;

-- 4b
USE sakila;
SELECT last_name, COUNT(*) as NUM
FROM actor 
GROUP BY last_name
HAVING COUNT(*) >1;

-- 4c
USE sakila;
SELECT actor_id
FROM actor
WHERE first_name = "Groucho" AND last_name = "Williams";

USE sakila;
UPDATE actor
SET first_name = "Harpo"
WHERE actor_id=172;

-- 4d
USE sakila;
UPDATE actor
SET first_name = "Groucho"
WHERE actor_id=172;

-- 5a 
CREATE TABLE address (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  /*!50705 location GEOMETRY NOT NULL,*/
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id),
  KEY idx_fk_city_id (city_id),
  /*!50705 SPATIAL KEY `idx_location` (location),*/
  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 6a
USE sakila;
SELECT 
	staff.first_name, 
    staff.last_name, 
    address.address
FROM
	staff
	INNER JOIN
    address
    ON
    staff.address_id = address.address_id;

-- 6b

USE sakila;
SELECT 
	staff.first_name, 
    staff.last_name, 
    SUM(payment.amount) 
FROM
	staff
	INNER JOIN
    payment
    ON
    staff.staff_id = payment.staff_id
    WHERE (payment_date between '2005-08-01 **00:00:00.000**' and '2005-08-31 **00:00:00.000**')
    GROUP BY last_name, first_name;

-- 6c

USE sakila;
SELECT 
	film.title, 
    COUNT(film_actor.actor_id) AS 'NUM of Actors'
FROM
	film
	INNER JOIN
    film_actor
    ON
    film.film_id = film_actor.film_id
    GROUP BY film.title;

-- 6d
USE sakila;
SELECT * 
FROM
	film
    WHERE
		film.title = "HUNCHBACK IMPOSSIBLE";
SELECT COUNT(film_id)
FROM inventory 
WHERE film_id = 439;

-- 6e
USE sakila;
SELECT 
	customer.first_name, 
    customer.last_name, 
    SUM(payment.amount) AS 'Total Amount Paid'
FROM
	customer
	INNER JOIN
    payment
    ON
    customer.customer_id = payment.customer_id
    GROUP BY last_name, first_name DESC;
    
-- 7a
USE sakila;
SELECT film.title
FROM film
WHERE title LIKE "K%" OR title LIKE "Q%" AND
language_id in
(
	SELECT language_id
    FROM language
    WHERE `name` = "English"
    );

-- 7b
USE sakila;
SELECT first_name, last_name
FROM actor
WHERE actor_id in
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id in
		(
			SELECT film_id
			FROM film
			WHERE title = "Alone Trip"
));

-- 7c
USE sakila;
SELECT 
	customer.first_name, 
    customer.last_name, 
    customer.email
FROM
	customer
	INNER JOIN
    address
    ON
    customer.address_id= address.address_id
    INNER JOIN
    city
    ON
    address.city_id =city.city_id
    INNER JOIN
    country
    ON
    city.country_id=country.country_id
    WHERE country.country ="Canada";
  
  -- 7d
  USE sakila;
  SELECT title
  FROM 
	film
	INNER JOIN 
		film_category
        ON
		film.film_id = film_category.film_id
		INNER JOIN
            category 
				ON 
                film_category.category_id = category.category_id
                WHERE name = "Family";
			
-- 7e
SELECT title, COUNT(*) AS 'Total_Times_Rented'
FROM film 
INNER JOIN
inventory 
ON
film.film_id = inventory.film_id
	INNER JOIN
    rental 
    ON
    inventory.inventory_id = rental.inventory_id
    GROUP BY film.title
    ORDER BY total_times_rented DESC;

-- 7f 
USE sakila;
SELECT store.store_id, SUM(payment.amount) AS 'Total Revenue'
FROM store 
INNER JOIN 
inventory
ON 
store.store_id = inventory.store_id
	INNER JOIN
    rental 
    ON
    inventory.inventory_id = rental.inventory_id 
		INNER JOIN 
        payment 
        ON 
        rental.rental_id = payment.rental_id
        GROUP BY store.store_id;
-- 7g 
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN 
address
ON 
store.address_id = address.address_id
	INNER JOIN
	city
    ON
    address.city_id= city.city_id 
		INNER JOIN 
        country 
        ON
        city.country_id = country.country_id;
        
-- 7h
USE sakila;
SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross_Revenue'
FROM category
INNER JOIN
film_category
ON 
category.category_id =film_category.category_id
	INNER JOIN 
    inventory
    ON 
    film_category.film_id = inventory.film_id
		INNER JOIN
        rental 
        ON 
        inventory.inventory_id = rental.inventory_id
			INNER JOIN 
            payment 
            ON
            rental.rental_id = payment.rental_id
            GROUP BY category.name 
            ORDER BY Gross_Revenue DESC
            LIMIT 5;
-- 8a

USE sakila;
CREATE VIEW top_five_genres
AS SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross_Revenue'
FROM category
INNER JOIN
film_category
ON 
category.category_id =film_category.category_id
	INNER JOIN 
    inventory
    ON 
    film_category.film_id = inventory.film_id
		INNER JOIN
        rental 
        ON 
        inventory.inventory_id = rental.inventory_id
			INNER JOIN 
            payment 
            ON
            rental.rental_id = payment.rental_id
            GROUP BY category.name 
            ORDER BY Gross_Revenue DESC
            LIMIT 5;
            
-- 8b
 USE sakila;
 SELECT * FROM top_five_genres;

-- 8c
USE sakila;
DROP VIEW top_five_genres;