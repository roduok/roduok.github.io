-- 1a Display the first and last names of all actors from the table actor.
USE sakila;
SELECT first_name, last_name
FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. 
USE sakila;
SELECT CONCAT(a.first_name, ' ', a.last_name) AS Actor_Name
FROM actor a;

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
USE sakila;
SELECT a.actor_id, a.first_name, a.last_name 
FROM actor a
WHERE a.first_name = "Joe";

-- 2b Find all actors whose last name contain the letters GEN:
USE sakila;
SELECT a.first_name, a.last_name 
FROM actor a
WHERE a.last_name LIKE "%GEN%";

-- 2c Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
USE sakila;
SELECT a.first_name, a.last_name 
FROM actor a
WHERE a.last_name LIKE "%LI%"
ORDER BY a.last_name, a.first_name ASC;

-- 2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
USE sakila;
SELECT c.country_id, c.country 
FROM country c
WHERE c.country in("Afghanistan", "Bangladesh", "China");

-- 3a Add a middle_name column to the table actor. Position it between first_name and last_name.
USE sakila;
alter table actor 
add column middle_name VARCHAR(255) AFTER first_name;

-- 3b You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
USE sakila;
alter table actor 
drop column middle_name;

alter table actor
add column middle_name BLOB AFTER first_name;

-- 3c Now delete the middle_name column.

USE sakila;
SELECT * FROM actor;
alter table actor 
drop column middle_name;

-- 4a List the last names of actors, as well as how many actors have that last name.
USE sakila;
SELECT last_name, count(*) as NUM 
FROM actor GROUP BY last_name;

-- 4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
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

-- 5a You cannot locate the schema of the address table. Which query would you use to re-create it?
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

-- 6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
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

-- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005. 

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

-- 6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

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

-- 6d How many copies of the film Hunchback Impossible exist in the inventory system?
USE sakila;
SELECT * 
FROM
	film
    WHERE
		film.title = "HUNCHBACK IMPOSSIBLE";
SELECT COUNT(film_id)
FROM inventory 
WHERE film_id = 439;

-- 6e Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
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
    
-- 7a Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
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

-- 7b Use subqueries to display all actors who appear in the film Alone Trip.
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

-- 7c You will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
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
  
  -- 7d You wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
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
			
-- 7e Display the most frequently rented movies in descending order.
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

-- 7f Write a query to display how much business, in dollars, each store brought in.
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
	
-- 7g Write a query to display for each store its store ID, city, and country.
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
        
-- 7h List the top five genres in gross revenue in descending order. 
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
	    
-- 8a Use the solution from the problem above to create a view. 
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
            
-- 8b How would you display the view that you created in 8a?
 USE sakila;
 SELECT * FROM top_five_genres;

-- 8c You find that you no longer need the view top_five_genres. Write a query to delete it.
USE sakila;
DROP VIEW top_five_genres;
