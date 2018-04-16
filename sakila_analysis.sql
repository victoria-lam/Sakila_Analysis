-- make sure correct database is working 
use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select actor.first_name, actor.last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name,' ', last_name)  as `Actor Name` from actor;
 
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select 	actor.actor_id, actor.first_name, actor.last_name from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor
where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor.last_name, actor.first_name from actor
where last_name like "%LI%"
order by last_name asc;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country.country_id, country.country from country
where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor 
add column middle_name varchar(45) after first_name;
select * from actor; -- check column 

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor
modify middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor
drop column middle_name;
select * from sakila.actor; -- check column

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(*) as 'number_of_actors' from sakila.actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,count(*) as 'number_of_actors' from sakila.actor
group by last_name 
having count(last_name)>1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update sakila.actor
set first_name = "HARPO"
where first_name = "GROUCHO" and last_name = "WILLIAMS";

select * from actor; -- check column

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
--     if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update sakila.actor
set first_name = case
	when first_name = "HARPO" and last_name = "WILLIAMS" then replace(first_name, "HARPO", "GROUCHO")
	else "MUCHO GROUCHO"
end
where actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
create table address_new like address;

insert into address_new (address_id, address, address2, district, city_id, postal_code, phone, location, last_update)
select * from address
order by address_id asc;

select * from address_new;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select * from staff;
select * from address;

select staff.first_name, staff.last_name, address.address from staff 
join address 
	on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select * from payment;

select staff.first_name, staff.last_name, p.amount from staff
join 
	(select payment.staff_id, sum(payment.amount) as amount 
	from payment
	where year(payment.payment_date) = "2005" and month(payment.payment_date) = "8"
	group by staff_id) as p
	on staff.staff_id =  p.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select * from film_actor;
select * from film;

select fa.film_id, f.title, count(fa.actor_id) as number_of_actors from film f
inner join film_actor fa 
	on f.film_id = fa.film_id
group by film_id, f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory;

select f.film_id, f.title, count(i.film_id) as inventory from film f 
inner join inventory i 
	on f.film_id = i.film_id
where f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select * from payment;
select * from customer;

select c.first_name, c.last_name, sum(p.amount) as total_paid from customer c
join payment p 
	on c.customer_id = p.customer_id
group by c.customer_id
order by last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
--     Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select * from film;
select * from language;

select f.title from film f
where f.title in 
	(select f.title from film f
	join language l 
		on l.language_id = f.language_id
	where f.title like "K%" or f.title like "Q%"
		and l.name = "English");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor;
select * from film_actor;
select * from film;

-- locate actor name with actor id for each movie 
select a.first_name, a.last_name from actor a
where a.actor_id in (
-- get actor id corresponding to name 
	select fa.actor_id from film_actor fa
    where fa.film_id in
-- get specific movie
		(select f.film_id from film f
		where f.title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select * from customer;
select * from address;
select * from city;
select * from country;

select cu.first_name, cu.last_name, cu.email from customer cu
join address a 
	on cu.address_id = a.address_id 		-- join on address id
join city ci 
	on a.city_id = ci.city_id		   		-- join on city id
join country co 
	on ci.country_id = co.country_id		-- join on country id
where co.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select * from film;
select * from film_category;
select * from category;

select f.title from film f
join film_category fc 
	on f.film_id = fc.film_id			-- join on film id
join category c 
	on fc.category_id = c.category_id 	-- join on category id
where c.name = "Family"								
order by f.title asc;

-- 7e. Display the most frequently rented movies in descending order.
select * from film; 
select * from inventory; 
select * from rental;	 

select f.title, count(r.rental_id) as number_of_rentals from film f
join inventory i 
	on f.film_id = i.film_id			-- join on film id
join rental r 
	on i.inventory_id = r.inventory_id	-- join on inventory id
group by f.title
order by number_of_rentals desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;		
select * from payment;

select a.id as 'store', sum(a.total_amount) as 'total amount' from (
select sto.store_id as id, 0 as total_amount from store sto
union all 
select p.staff_id as id, sum(p.amount) as total_amount from payment p
group by p.staff_id) a
group by a.id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select * from store;
select * from address;
select * from city;
select * from country;

select s.store_id, ci.city, co.country from store s
inner join address a 
	on s.address_id = a.address_id
inner join city ci 
	on a.city_id = ci.city_id
inner join country co 
	on ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;

select c.name as 'Genres', sum(p.total_amount) as 'Gross_Revenue' from rental r
inner join inventory i 
	on r.inventory_id = i.inventory_id
inner join film_category fc 
	on i.film_id = fc.film_id
inner join category c
	on fc.category_id = c.category_id
left join (
	select p.rental_id, sum(p.amount) as total_amount from payment p	-- total amount for each rental id
	group by p.rental_id
    ) p 
		on r.rental_id = p.rental_id
group by c.name
order by Gross_Revenue desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
drop view if exists top_five_genres_by_gross_revenue;

create view top_five_genres_by_gross_revenue as 
select c.name as 'Genres', sum(p.total_amount) as 'Gross_Revenue' from rental r
inner join inventory i 
	on r.inventory_id = i.inventory_id
inner join film_category fc 
	on i.film_id = fc.film_id
inner join category c 
	on fc.category_id = c.category_id
left join (
	select p.rental_id, sum(p.amount) as total_amount from payment p	-- total amount for each rental id
	group by p.rental_id
    ) p 
		on r.rental_id = p.rental_id
group by c.name
order by Gross_Revenue desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres_by_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres_by_gross_revenue;