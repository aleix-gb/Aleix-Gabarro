select * from transaction;
select * from company;

-- Using JOIN, perform the following queries:
-- Lvl 1.Ex2.a: List of countries that are making purchases.
select distinct c.country from company as c
left join transaction as t on c.id=t.company_id
order by c.country;

-- Lvl 1.Ex2.b: From how many countries are purchases being made?
select count(distinct c.country) from company as c
left join transaction as t on c.id=t.company_id;

-- Lvl 1.Ex2.c: Identify the company with the highest average sales.
select c.company_name, round(avg(t.amount), 2) as mitjana from transaction as t
left join company as c on t.company_id=c.id
group by c.company_name
order by mitjana desc
limit 1;

-- Using only subqueries (without using JOIN):
-- Lvl 1.Ex3.a: Show all transactions carried out by companies from Germany.
select * from transaction
where company_id in (select id from company 
	where country = "Germany");

-- Lvl 1.Ex3.b: List the companies that have made transactions with an amount greater than the average of all transactions.
select distinct company_name from company
where id in (select company_id from transaction
	where amount > (select avg(amount) from transaction))
order by company_name;

-- Lvl 1.Ex3.c: Companies without any recorded transactions will be removed from the system — provide a list of these companies
SELECT company_name FROM company
WHERE NOT EXISTS( SELECT * FROM transaction
        WHERE transaction.company_id = company.id)
ORDER BY company_name;

-- Lvl 2.Ex1: Identify the five days on which the company generated the highest revenue from sales. Show the date of each transaction along with the total sales.
select date(timestamp) data, sum(amount) total from transaction
group by data
order by total desc
limit 5;

-- Lvl 2.Ex2: What is the average sales amount per country? Present the results sorted from highest to lowest average.
select c.country, round(avg(amount), 2) as mitjana from company as c
left join transaction as t on c.id=t.company_id
left join (select company_id, avg(amount) from transaction group by company_id) avgamountcountry
on c.id=avgamountcountry.company_id
group by c.country
order by avg(amount) desc;

-- Lvl 2.Ex3.a: Your company is considering a new project to launch advertising campaigns to compete with the company "Non Institute". For this, you are asked for the list of all transactions made by companies located in the same country as this company.
-- Show the list using JOIN and subqueries.
select c.company_name, t.* from transaction as t
left join company as c on t.company_id=c.id
where country = (select country from company
	where company_name = "Non Institute");
    
-- Lvl 2.Ex3.b: Show the list using only subqueries.
select * from transaction
where company_id in (select id from company 
	where country = (select country from company where company_name = "Non Institute"));

-- Lvl 3.Ex1: Present the name, phone number, country, date, and amount of those companies that made transactions with a value between 100 and 200 euros and on any of the following dates: April 29, 2021; July 20, 2021; and March 13, 2022. Sort the results from highest to lowest amount.
select c.company_name, c.phone, c.country, date(timestamp) data, t.amount from company c
left join transaction as t on c.id=t.company_id
where (t.amount between 100 and 200) and (date(timestamp) in ("2021-04-29", "2021-07-20", "2022-03-13"))
order by t.amount desc;

-- Lvl 3.Ex2: We need to optimize resource allocation depending on the operational capacity required. Therefore, you're asked to provide information about the number of transactions each company carries out. The Human Resources department is demanding and wants a list of companies where you specify whether they have more than 4 transactions or less.
select c.company_name, count(company_id) num_transaccions,
case
	when count(company_id) >= 4 then "4 o més"
	else "Menys de 4"
end as Recompte 
from company c
left join transaction t on c.id=t.company_id
group by c.company_name
order by count(company_id) desc;