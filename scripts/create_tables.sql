--Se crea la Base de Datos 
create database RealStateUSA

use RealStateUSA

--Se crea la tabla con los compos y los tipo de datos que contiene el dataset
create table property(
	property_id int primary key identity(1,1),
	brokered_by varchar(20),
	status varchar(20),
	price numeric(15,2),
	bed int,
	bath int,
	acre_lot numeric(15,2),
	street varchar(50),
	city varchar(50),
	state varchar(50),
	zip_code varchar(10),
	house_size numeric(15),
	prev_sold_date date
)

--creamos la tabla espejo donde se importaran los registros del dataset
create table estaging_property(
	brokered_by varchar(20),
	status varchar(20),
	price numeric(15,2),
	bed int,
	bath int,
	acre_lot numeric(15,2),
	street varchar(50),
	city varchar(50),
	state varchar(50),
	zip_code varchar(20),
	house_size numeric(15),
	prev_sold_date varchar(20)
)

--Importamos e insertamos en la tabla temporal los registros del dataset, 
--Esto se hace para evitar que se genere error por el campo property_id que no esta incluido en el dataset descargado
BULK INSERT estaging_property
FROM 'E:\Proyecto_Real_State_USA\realtor-data.zip.csv'
WITH(
	firstrow = 2,
	format = 'CSV',
	FIELDQUOTE = '"',
	fieldterminator = ',',
	rowterminator = '0x0a',
	tablock
)

-- Pasamos los registros de la tabla temporal a la tabla final
insert into property (brokered_by, status, price, bed, bath, acre_lot, street, city, state, zip_code, house_size, prev_sold_date)
select brokered_by, 
	   status, 
	   price, 
	   bed, 
	   bath, 
	   acre_lot, 
	   street, 
	   city, 
	   state, 
	   zip_code, 
	   house_size, 
	   try_convert(date, prev_sold_date)
from estaging_property


--Eliminamos la tabla temporal
drop table estaging_property