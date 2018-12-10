--  We start with the database we're going to use
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
-- We're doing this with just a select statement
SELECT first_name, last_name FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters
-- the column will be named 'Actor Name'

SELECT CONCAT(first_name,' ', last_name) AS 'Actor name' FROM actor;

-- 2a. find the ID number, first name, and last name of an actor who's first name is "joe." 
-- Let's run a query on Joe

SELECT first_name, last_name FROM actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`

SELECT * FROM actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
where country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
Drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name HAVING COUNT(last_name) >1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor 
SET first_name = "HARPO" 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT * FROM staff m, address p
where m.address_id = p.address_id;

-- film_actor6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT *, sum(amount) AS 'Total amount (dollars)' FROM staff m, payment p
where m.staff_id = p.staff_id and payment_date like "2005-08%"
GROUP BY m.first_name, m.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
-- SELECT * FROM film_actor m, film p
-- where m.film_id = p.film_id;

SELECT *, COUNT(p.film_id) AS 'Total number of actors' FROM film p
	INNER Join film_actor m 
		ON m.film_id=p.film_id
GROUP BY p.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT *, COUNT(m.film_id) AS 'Total number' FROM inventory m
	INNER JOIN film p
		ON p.film_id = m.film_id
        WHERE p.title = "Hunchback Impossible";
-- GROUP BY p.film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

--  ![Total amount paid](Images/total_payment.png)

SELECT *, SUM(p.amount) as 'Total Paid' from payment p
	INNER JOIN customer c
		ON p.customer_id = c.customer_id
Group by p.customer_id
order by last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
	FROM film
	WHERE language_id IN
  (
    SELECT language_id
    FROM language 
    WHERE name = "English" )
	AND title like "K%" or 
    title like "Q%";
    
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
    SELECT film_id
    FROM film 
    WHERE title = 'Alone Trip'
  ) 
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- customer (customer_id, address_id), address (address_id, city_id), city(city_id, country_id), country (country_id)
SELECT c.first_name, c.last_name, c.email from customer c
	INNER JOIN address a
		ON c.address_id = a.address_id
	INNER JOIN city i
		ON i.city_id = a.city_id
	INNER JOIN country o
		ON i.country_id = o.country_id
WHERE o.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT title
FROM film
WHERE film_id IN
(
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (
    SELECT category_id
    FROM category 
    WHERE name = 'Family'
  ) 
);

-- 7e. Display the most frequently rented movies in descending order.
-- rental (inventory_id), inventory (inventory_id, film_id), film (film_id, title)
-- , COUNT(r.rental_id) AS 'Total number of rentals'
SELECT f.title AS 'Movie Title', COUNT(r.inventory_id) AS 'TOTAL RENTALS' FROM rental r
	INNER Join inventory i 
		ON r.inventory_id=i.inventory_id
	INNER JOIN film f
		ON i.film_id = f.film_id
GROUP BY f.film_id
ORDER BY COUNT(r.inventory_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- store (store id, address_id), address (address_id), inventory (store_id, inventory_id) rental (rental_id, inventory_id), payment (amount, rental_id),

SELECT a.address AS 'Stores', SUM(p.amount) AS 'Amount Earned' FROM payment p
	INNER JOIN rental r
		ON r.rental_id = p.rental_id
	INNER JOIN inventory i
		ON i.inventory_id = r.inventory_id
	INNER JOIN store s
		ON s.store_id = i.store_id
	INNER JOIN address a
		ON a.address_id = s.address_id
GROUP BY a.address_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- store (store_id, address_id), address (address_id, city_id), city (city_id, country_id), country (country_id)

SELECT s.store_id, c.city, o.country from store s
	INNER JOIN address a
		ON s.address_id = a.address_id
	INNER JOIN city c
		ON a.city_id = a.city_id
	INNER JOIN country o
		ON o.country_id = c.country_id
GROUP BY a.address_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- category (category_id, name), film_category (film_id, category_id), inventory (film_id, inventory_id), payment (rental_id, amount), rental (rental_id, inventory_id)

CREATE TABLE top_genres 
SELECT c.name, SUM(p.amount) AS 'Total Amount Earned' FROM payment p
	INNER JOIN rental r
		ON r.rental_id = p.rental_id
	INNER JOIN inventory i
		ON r.inventory_id = i.inventory_id
	INNER JOIN film_category f
		ON i.film_id = f.film_id
	INNER JOIN category c
		ON f.category_id = c.category_id
GROUP BY c.name;
	
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS `top_genres_view`;
CREATE VIEW top_genres_view AS
SELECT *
FROM top_genres;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_genres_view;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS `top_genres_view`;
    