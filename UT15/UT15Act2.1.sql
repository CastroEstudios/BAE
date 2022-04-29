
use paro
go
-- En la BD Paro. Realiza un procedimiento almacenado al que se pasa el codProvincia, el mes y el año del estudio, poner año=2013 por defecto
--y despues de mostrar el paro total de cada municipio y el paro de los municipios con paro superior a la media de paro en la provincia,
--devuelve el paro medio en la provincia, el num de municipios cuyo paro supera la media y el nombre del municipio con más parados
-- el procedimiento comprueba que exista en la BD el codProv y que el número de mes sea correcto (1,2 o 3)
-- hacer ejecución para Las Palmas con datos de la estadística de febrero 2013

if object_id('pa_InformaParoProv','P') is not null 
drop procedure pa_InformaParoProv
go 

create procedure pa_InformaParoProv
@codProv tinyint, @mes tinyint, @agno tinyint = 2013,
@pm decimal (8,2) output, @num tinyint output, @nom varchar(30) output
as

select
	CodMunicipio,
	(select Municipio from Municipios as m where m.CodMunicipio = pm.CodMunicipio)
	TotalParoRegistrado
from ParoMes as pm
where YEAR(Fecha) = @agno and MONTH(Fecha) = @mes

set @pm = 
(
	select
		round(avg(TotalParoRegistrado),2) as 'Promedio provincia'
	from ParoMes as pm
	join Municipios as m
	on pm.CodMunicipio = m.CodMunicipio
	where m.CodProvincia = @codProv and YEAR(Fecha) = @agno and MONTH(Fecha) = @mes
)

select
	CodMunicipio,
	(select Municipio from Municipios as m where m.CodMunicipio = pm.CodMunicipio),
	TotalParoRegistrado
from ParoMes as pm
where YEAR(Fecha) = 2013 and MONTH(Fecha) = 02 and TotalParoRegistrado > @pm
set @num = @@ROWCOUNT

set @nom = (
	select 
		MAX(TotalParoRegistrado)
	from Municipios as m
	join ParoMes as pm
	on m.CodMunicipio = pm.CodMunicipio
	)

--Prueba ejecución

exec pa_InformaParoProv 38, 01, 2013, 


-- ejecución con errores

