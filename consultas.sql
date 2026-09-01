--¿Cuál es el precio promedio de las propiedades?
select ROUND(AVG(price),2) as precio_promedio
from property
where price IS NOT NULL
and price > 0

--¿Qué ciudades tienen las propiedades más caras?
select top 5 city,
	   AVG(price) precio_promedio
from property
where price > 0 
and price IS NOT NULL
group by city
order by precio_promedio desc

--¿Cuál es el precio promedio por estado?
select state as estado,
	   ROUND(AVG(price),2) as precio_promedio
from property
where price > 0 
and price IS NOT NULL
group by state
order by precio_promedio desc

--¿Dónde existe mayor cantidad de propiedades?
select city as ciudad,
	   COUNT(*) as Total_Propiedades
from property
group by city
order by Total_Propiedades desc

--¿Cómo cambia el precio según número de dormitorios?
select bed as dormitorios,
	   ROUND(AVG(price),2) as precio_promedio
from property
where price > 0 
and price IS NOT NULL
group by bed
order by bed desc,
	     precio_promedio desc

--¿Qué relación existe entre tamaño y precio?
select 
	CASE 
		WHEN house_size < 1000 THEN 'Menos de 1000 sqft'
		WHEN house_size BETWEEN 1000 and 1999 THEN '1000-1999 sqft'
		WHEN house_size BETWEEN 2000 and 2999 THEN '2000-2999 sqft'
		WHEN house_size BETWEEN 3000 and 3999 THEN '3000-3999 sqft'
		ELSE '+4000 sqft'
	END AS Rango_tamanio,
	ROUND(AVG(price),2) as Precio_promedio,
	COUNT(*) as Total_propiedades
from property
where price > 0
and price is not null
group by 
	CASE 
		WHEN house_size < 1000 THEN 'Menos de 1000 sqft'
		WHEN house_size BETWEEN 1000 and 1999 THEN '1000-1999 sqft'
		WHEN house_size BETWEEN 2000 and 2999 THEN '2000-2999 sqft'
		WHEN house_size BETWEEN 3000 and 3999 THEN '3000-3999 sqft'
		ELSE '+4000 sqft'
	END
order by min(house_size)

--¿Cuáles son las 10 propiedades más caras? 
select top 10 
	   property_id as propiedad_id,
	   price as precio
from property
order by precio desc

--¿Cuál es la propiedad más cara de cada ciudad?
with cte_ranking_ciudad as (
	select property_id as propiedad_id,
		   city as ciudad,
		   price as precio,
		   DENSE_RANK() OVER(
				PARTITION BY city 
				order by price desc)
				as ranking
	from property
	where city is not null
)

select propiedad_id,
	   ciudad,
	   precio
from cte_ranking_ciudad
where ranking = 1

--¿Qué propiedades están sobre el precio promedio de su ciudad?
select property_id as propiedad_id,
	   price as precio,
	   city as ciudad
from property as p1
where price > ( select AVG(price) 
			   from property as p2
			   where p1.city = p2.city
			   )
and price > 0 
and price IS NOT NULL

--¿Cuál es el ranking de propiedades por precio dentro de cada ciudad?
select property_id as propiedad_id,
	   price as propiedad_precio,
	   coalesce(city, 'Sin Ciudad') as propiedad_ciudad,
	   DENSE_RANK() OVER(partition by city 
		             order by price desc)
					 as Ranking
from property
where price > 0 
	and price IS NOT NULL


--¿Qué porcentaje de las propiedades corresponde a cada estado?
with cte_prpiedades as(
	select coalesce(state, 'Sin Estado') as estado,
		COUNT(*) as propiedades_por_estado,
		(select count(*)
		 from property
		) as total_propiedades
	from property
	group by state 
)
select estado,
	   propiedades_por_estado,
	   ((propiedades_por_estado / CAST(total_propiedades as decimal(10,2))) * 100) as procentaje
from cte_prpiedades

--¿Cuánto se aleja cada propiedad del precio promedio de su zona?
with cte_promedio_precio_ciudad as (	
	select property_id as propiedad_id,
		coalesce(city, 'Sin Ciudad') as ciudad,
		price as precio,
		AVG(price) OVER(partition by city) as precio_promedio_ciudad
	from property
	where price > 0
	and price IS NOT NULL
)
select propiedad_id,
	   ciudad,
	   precio,
	   precio_promedio_ciudad,
	   precio - precio_promedio_ciudad as diferencia
from cte_promedio_precio_ciudad

--¿Cómo evolucionan los precios en el tiempo?
with cte_promedio_precio as (
	select YEAR(prev_sold_date) as anio,
		AVG(price) as promedio_precio_anio,
		LAG(AVG(price)) OVER(order by YEAR(prev_sold_date) asc) as promedio_precio_anio_anterior
	from property
	where YEAR(prev_sold_date) IS NOT NULL
	and price IS NOT NULL
	and price > 0
	group by YEAR(prev_sold_date)
)
select anio,
	   promedio_precio_anio,
	   promedio_precio_anio_anterior,
	   ISNULL(promedio_precio_anio - promedio_precio_anio_anterior,0) as diferencia
from cte_promedio_precio
order by anio ASC

--Cuál es el promedio móvil de precios? (3 periodos)
With cte_promedio_anio as (
	select YEAR(prev_sold_date) as anio,
		AVG(price) as promedio_precio_anio
	from property
	WHERE price IS NOT NULL
	and price > 0 
	and prev_sold_date is not null
	group by YEAR(prev_sold_date)
	
)
select anio,
	   promedio_precio_anio,
	   AVG(promedio_precio_anio) over(order by anio ASC
				   ROWS BETWEEN 2 PRECEDING and CURRENT ROW
				   ) as promedio_movil
from cte_promedio_anio
order by anio ASC

--¿Qué ciudades combinan alta oferta + precios elevados?
With cte_data_ciudades as (
	select city as ciudad,
		count(*) as propiedades,
		AVG(price) as precio_promedio
	from property
	where price > 0 
	and price IS NOT NULL
	group by city
)
select ciudad,
	   propiedades,
	   precio_promedio
from cte_data_ciudades
where propiedades > 
	   (SELECT AVG(numero_propiedades)
	    from(
			SELECT count(*) as numero_propiedades
		    from  property
			group by city) 
			as promedio_por_ciudad)

and precio_promedio > 
	(
	  select AVG(price)
	  from property
	  where price > 0 
	  and price IS NOT NULL
	)




	SELECT COUNT(*) FROM property