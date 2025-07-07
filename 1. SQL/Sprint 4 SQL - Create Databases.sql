create database s4_transactions;

create table transactions (
id varchar(255) primary key not null,
card_id varchar(15),
business_id varchar(10),
timestamp timestamp,
amount decimal(10,2),
declined tinyint(1),
product_ids varchar(50),
user_id int(11),
lat float,
longitude float
);

show global variables like "local_infile";
set global local_infile=1;

LOAD DATA LOCAL INFILE 'C:/Users/Griselda/Desktop/Bootcamp Data Analytics/Sprint 4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from transactions;

create table credit_cards (
id varchar(15) primary key not null,
user_id int(11),
iban varchar(50),
pan varchar(50),
pin varchar(4),
cvv int(11),
track1 varchar(250),
track2 varchar(250),
expiring_date varchar(20)
);

LOAD DATA LOCAL INFILE 'C:/Users/Griselda/Desktop/Bootcamp Data Analytics/Sprint 4/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

select * from credit_cards;

create table companies (
company_id varchar(10) primary key,
company_name varchar(255),
phone varchar(15),
email varchar(100),
country varchar(100),
website varchar(100)
);

LOAD DATA LOCAL INFILE 'C:/Users/Griselda/Desktop/Bootcamp Data Analytics/Sprint 4/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from companies;

create table users (
id int(11) primary key not null,
name varchar(75),
surname varchar(75),
phone varchar(50),
email varchar(100),
birth_date varchar(20),
country varchar(100),
city varchar(100),
postal_code varchar(10),
address varchar(150)
);

LOAD DATA LOCAL INFILE 'C:/Users/Griselda/Desktop/Bootcamp Data Analytics/Sprint 4/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Griselda/Desktop/Bootcamp Data Analytics/Sprint 4/users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/Griselda/Desktop/Bootcamp Data Analytics/Sprint 4/users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from users;

create index idx_companies on companies(company_id);
create index idx_credit_cards on credit_cards(id);
create index idx_transactions on transactions(id);
create index idx_users on users(id);

alter table transactions
add constraint fk_user_id foreign key (user_id) REFERENCES users(id);

alter table transactions
add constraint fk_card_id foreign key (card_id) REFERENCES credit_cards(id);

alter table transactions
add constraint fk_business_id foreign key (business_id) REFERENCES companies(company_id);

-- Lvl 1.Ex1: Write a query that shows all users with more than 30 transactions, using at least 2 tables
select u.id, u.name, u.surname, count(user_id) transaccions from transactions t
left join users u on t.user_id=u.id
group by u.id, u.name, u.surname
having transaccions >30
order by transaccions desc;

-- Lvl 1.Ex2: Show the average amount per IBAN of credit cards in the company Donec Ltd, using at least 2 tables.
select c.company_id, c.company_name, cc.iban, round(avg(amount), 2) mitjana from transactions t
left join companies c on t.business_id=c.company_id
left join credit_cards cc on t.card_id=cc.id
where c.company_name = "Donec Ltd"
group by c.company_id, c.company_name, cc.iban;


-- Level 2: Create a new table that reflects the status of credit cards, based on whether the last three transactions were declined. Then generate the following query:
-- Lvl 2.Ex1: How many credit cards are active?
create table active_cards as select card_id, timestamp, declined from transactions;

select * from active_cards;

with tarja_activa as (
select card_id, declined,
	row_number () over (partition by card_id order by timestamp desc) as partition_time 
 from active_cards
 )
 select card_id, 
 case 
	when sum(declined) <3 then "Activa"
    else "Inactiva"
    end as estat
from tarja_activa
where partition_time <=3
group by card_id
having estat = "activa";

-- Level 3: Create a table to allow you to join the data from the new products.csv file with the existing database, taking into account that the transaction table has a product_ids field. Then generate the following query:
-- Lvl 3.Ex1: We need to know how many times each product has been sold
select * from sold_products;
create table sold_products as select id, product_ids from transactions;

create table products (
id int(11) primary key not null,
product_name varchar(75),
price varchar(10),
colour varchar(50),
weight varchar(100),
warehouse_id varchar(20)
);

LOAD DATA LOCAL INFILE 'C:/Users/Griselda/Desktop/Bootcamp Data Analytics/Sprint 4/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

select * from products;

with prods_indiv as (
select id, productes.product_id
from sold_products
join json_table (concat("[", product_ids, "]" ),
"$[*]" columns (product_id varchar(100) path "$")
 )  as productes
)
select product_id, count(product_id) recompte from prods_indiv
group by product_id
order by product_id;

/* select distinct p.id, count(product_ids) as comptador from sold_products sp
join products p on sp.product_ids=p.id
group by p.id
order by comptador desc; */