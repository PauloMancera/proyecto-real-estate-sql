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