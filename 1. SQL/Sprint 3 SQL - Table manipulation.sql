-- Lvl 1.Ex1: Design and create a table called "credit_card" that stores crucial details about credit cards. The new table must be able to uniquely identify each card and establish an appropriate relationship with the other two tables ("transaction" and "company"). After creating the table, you will need to insert the information from the document named "dades_introduir_credit".
create index idx_credit_card on credit_card(id);

CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY,
        iban VARCHAR(50),
        pan VARCHAR(30),
        pin VARCHAR(4),
        cvv VARCHAR(100),
        expiring_date VARCHAR(20)
    );

alter table transaction
add constraint fk_credit_card_id foreign key (credit_card_id) REFERENCES credit_card(id);

-- Lvl 1.Ex2: The Human Resources department has identified an error in the account number of the user with ID CcU-2938. The information that should be shown for this record is: R323456312213576817699999. Remember to show that the change has been made.
select * from credit_card
where id="CcU-2938";

update credit_card
set iban = "R323456312213576817699999"
where id="CcU-2938";

select * from credit_card
where id="CcU-2938";

-- Lvl 1.Ex3: In the table "transaction", insert a new user with the following information:
/* id: 108B1D1D-5B23-A76C-55EF-C568E49A99DD  
credit_card_id:     CcU-9999  
company_id:         b-9999  
user_id:            9999  
lat:                829.999  
longitude:         -117.999  
amount:             111.11  
declined:           0 */

select * from company
where id="b-9999";

select * from credit_card 
where id="ccu-9999";

insert into company (id) values ("b-9999");
insert into credit_card (id) values ("CcU-9999");
insert into transaction (id, credit_card_id, company_id, user_id,
lat, longitude, timestamp, amount, declined)
values ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", 9999,
"829.999", "-117.999", datetime, "111.11", 0);

update transaction
set timestamp = now()
where id="108B1D1D-5B23-A76C-55EF-C568E49A99DD";

select * from company
where id="b-9999";
select * from credit_card
where id="CcU-9999";
select * from transaction
where id="108B1D1D-5B23-A76C-55EF-C568E49A99DD";

-- Lvl 1.Ex4: The Human Resources department asks you to remove the column pan from the credit_card table.
alter table credit_card
drop column pan;

-- Lvl 2.Ex1: Delete from the transaction table the record with ID: 02C6201E-D90A-1859-B4EE-88D2986D3B02
delete from transaction
where id="02C6201E-D90A-1859-B4EE-88D2986D3B02";

select * from transaction
where id="02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- Lvl 2.Ex2: The Marketing department wants access to specific information for effective analysis and strategy. You are asked to create a view called VistaMarketing containing the following details: company_name, phone, country, avg(amount)
select c.company_name, c.phone, c.country, round(avg(amount), 2) as mitjana_amount from company c
left join transaction t on c.id=t.company_id
group by c.company_name, c.phone, c.country
order by avg(amount) desc;

-- Lvl 2.Ex3: Filter the VistaMarketing view to show only the companies whose country of residence is "Germany"
select c.company_name, c.phone, c.country, round(avg(amount), 2) as mitjana_amount from company c
left join transaction t on c.id=t.company_id
where c.country="Germany"
group by c.company_name, c.phone, c.country
order by avg(amount) desc;

-- Lvl 3.Ex1: A colleague from your team made changes to the database but doesn’t remember how. They ask for your help to reconstruct the commands executed to get the resulting diagram
alter table company
drop column website;

alter table credit_card
add fecha_actual date;

alter table credit_card
modify column cvv INT;

alter table transaction
add constraint fk_user_id foreign key (user_id) REFERENCES user(id);
 
show create table data_user;

alter table user
drop foreign key user_ibfk_1;

set foreign_key_checks=0;

alter table transaction
add constraint fk_user_id foreign key (user_id) REFERENCES user(id);

set foreign_key_checks=1;

alter table user rename data_user;

alter table data_user rename column email to personal_email;

-- Lvl 3. Ex2: The company also asks you to create a view called InformeTecnico containing the following information:Transaction ID, User first name, User last name, IBAN of the credit card used, Name of the company involved in the transaction.Display the results of the view, ordered descending by the transaction ID.
select t.id transacció, u.name, u.surname, cc.iban, c.company_name empresa from transaction t
left join company c on t.company_id=c.id
left join credit_card cc on t.credit_card_id=cc.id
left join data_user u on t.user_id=u.id
order by t.id desc;