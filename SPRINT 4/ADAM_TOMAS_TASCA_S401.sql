CREATE DATABASE transas;


-- Cremos la tabla users_ca
CREATE TABLE IF NOT EXISTS users_ca (
  id int(11) PRIMARY KEY,
  name text,
  surname text,
  phone varchar(20) DEFAULT NULL,
  email varchar(100) DEFAULT NULL,
  birth_date varchar(50) DEFAULT NULL,
  country text,
  city text,
  postal_code varchar(50) DEFAULT NULL,
  address varchar(250) DEFAULT NULL
); 

-- Cremos la tabla users_uk
CREATE TABLE IF NOT EXISTS users_uk (
  id int(11) PRIMARY KEY,
  name text,
  surname text,
  phone varchar(20) DEFAULT NULL,
  email varchar(100) DEFAULT NULL,
  birth_date varchar(50) DEFAULT NULL,
  country text,
  city text,
  postal_code varchar(50) DEFAULT NULL,
  address varchar(250) DEFAULT NULL
); 

-- Cremos la tabla users_usa
CREATE TABLE IF NOT EXISTS users_usa (
  id int(11) PRIMARY KEY,
  name text,
  surname text,
  phone varchar(20) DEFAULT NULL,
  email varchar(100) DEFAULT NULL,
  birth_date varchar(50) DEFAULT NULL,
  country text,
  city text,
  postal_code varchar(50) DEFAULT NULL,
  address varchar(250) DEFAULT NULL
); 

-- Cremos la tabla users
CREATE TABLE IF NOT EXISTS users (
  id int(11) PRIMARY KEY,
  name text,
  surname text,
  phone varchar(20) DEFAULT NULL,
  email varchar(100) DEFAULT NULL,
  birth_date varchar(50) DEFAULT NULL,
  country text,
  city text,
  postal_code varchar(50) DEFAULT NULL,
  address varchar(250) DEFAULT NULL
); 

-- añadimos los registros de la tabla users_ca a la tabla users
INSERT INTO users 
SELECT * FROM users_ca;

-- añadimos los registros de la tabla users_usa a la tabla users
INSERT INTO users 
SELECT * FROM users_usa;

-- añadimos los registros de la tabla users_uk a la tabla users
INSERT INTO users 
SELECT * FROM users_uk;

-- Creamos la tabla companies
CREATE TABLE IF NOT EXISTS companies (
  id VARCHAR(15) PRIMARY KEY NOT NULL,
  company_name VARCHAR(255) NULL DEFAULT NULL,
  phone VARCHAR(15) NULL DEFAULT NULL,
  email VARCHAR(100) NULL DEFAULT NULL,
  country VARCHAR(100) NULL DEFAULT NULL,
  website VARCHAR(255) NULL DEFAULT NULL
   
);

-- Creamos la tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
  id VARCHAR(20) PRIMARY KEY NOT NULL,
  user_id INT(11) NULL DEFAULT NULL,
  iban VARCHAR(50) NULL DEFAULT NULL,
  pan VARCHAR(20) NULL DEFAULT NULL,
  pin VARCHAR(4) NULL DEFAULT NULL,
  cvv INT(11) NULL DEFAULT NULL,
  track1 VARCHAR(79) NULL DEFAULT NULL,
  track2 VARCHAR(40) NULL DEFAULT NULL,
  expiring_date VARCHAR(10) NULL DEFAULT NULL

);

-- Cremos la tabla transaction
 CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(255) PRIMARY KEY NOT NULL,
    card_id VARCHAR(20) REFERENCES credit_cards(id),
    business_id VARCHAR(20),
    timestamp TIMESTAMP,
    amount DECIMAL(10, 2),
    declined BOOLEAN,
    products_id VARCHAR(20) REFERENCES products(id),
    user_id INT REFERENCES users(id),
    lat FLOAT,
    longitude FLOAT
); 



#EXERCICI 1
#Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT id,name
FROM users
WHERE id IN (SELECT user_id
				FROM transactions
				GROUP BY user_id
				HAVING COUNT(amount) > 30);
                
#EXERCICI 2
#Mostra la mitjana de la suma de transaccions per IBAN de les targetes de crèdit
#en la companyia Donec Ltd. utilitzant almenys 2 taules.

-- cambiamos el nombre del campo business_id por company_id para que sea más reconocible.
ALTER TABLE transactions
CHANGE business_id company_id varchar(20);


SELECT AVG(t.amount) as MediaAmount
FROM transactions t
JOIN companies c
ON c.id = t.company_id
JOIN (SELECT cc.iban, SUM(t.amount) as Total_amount
		FROM transactions t
		JOIN credit_cards cc
		ON t.card_id = cc.id
		GROUP BY cc.iban) SumTotal
WHERE company_name = 'Donec Ltd'
GROUP BY company_id;



#NIVELL 2
#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions
#van ser declinades i genera la següent consulta:
#EXERCICI 1
#Quantes targetes estan actives?

-- Creamos la tabla credit_card_status
CREATE TABLE IF NOT EXISTS credit_card_status AS 

SELECT card_id,
	CASE 
		WHEN SUM(declined)>= 3 THEN 'Blocked'
			ELSE 'Active'
		END AS card_status
FROM (SELECT card_id, timestamp, declined, 
		ROW_NUMBER() OVER (PARTITION BY card_id
							ORDER BY timestamp DESC) AS num_registro
		FROM transactions) AS Registers
WHERE num_registro<=3
GROUP BY card_id;


SELECT card_id,card_status
FROM credit_card_status
WHERE card_status = 'Active';

#Todas las tarjetas de credito están activas, no hay ninguna que las últimas 3 transacciones hayan sido declinadas.

#NIVELL 3

#Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
#tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

#EXERCICI 1
#Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

CREATE TABLE IF NOT EXISTS products (
  id INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  product_name TEXT NULL DEFAULT NULL,
  price VARCHAR(100) NULL DEFAULT NULL,
  colour VARCHAR(100) NULL DEFAULT NULL,
  weight FLOAT NULL DEFAULT NULL,
  warehouse_id VARCHAR(11) NULL DEFAULT NULL
   
);
  
SELECT p.product_name,COUNT(p.id) AS Num_Sales
FROM transactions t
JOIN products p 
ON FIND_IN_SET(p.id, REPLACE(t.products_id, ' ', '')) > 0
GROUP BY p.product_name;

#Se tiene que ordenar por product_name, porque hay varios productos que se llaman igual pero tienen diferentes ID's.
