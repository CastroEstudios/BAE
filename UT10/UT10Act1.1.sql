
use AlquilerCoches
go

-- 1.- alquileres de veh�culos '....-BH.'. Indicar adem�s del DNI y la matricula el nombre y apellidos del cliente concatenados, 
-- la fecha de alquiler, los d�as alquilado. Todo ordenado por fecha. 

select 
	aa.Matricula,
	aa.DNICliente,
	CONCAT(ac.Apellidos,' ', ac.Nombre) as 'Nombre y Apellidos',
	aa.FechaInicio as 'Fecha alquiler',
	DATEDIFF(day, FechaInicio, FechaFinal) as 'Dias alquiler'
from ALQ_Alquiler as aa
join ALQ_Cliente as ac
on aa.DNICliente = ac.DNICliente
where Matricula like '[0-9][0-9][0-9][0-9]-BH%'
order by FechaInicio desc
go

select 
	aa.Matricula,
	aa.DNICliente,
	CONCAT((select Nombre from ALQ_Cliente as ac where ac.DNICliente=aa.DNICliente), 
	' ', (select Apellidos from ALQ_Cliente as ac where ac.DNICliente = aa.DNICliente)) 
	as 'Nombre y Apellidos',
	aa.FechaInicio as 'Fecha alquiler',
	DATEDIFF(day, FechaInicio, FechaFinal) as 'Dias alquiler'
from ALQ_Alquiler as aa
where Matricula like '[0-9][0-9][0-9][0-9]-BH%'
order by FechaInicio desc
go

--2.- N�mero de alquileres de cada veh�culo, indicando la matricula y la descripci�n del tipo. Ordenar de mayor a menor por n�alquileres.

select 
	count(*) as 'Nalquileres vehiculo',
	aa.Matricula,
	DescripcionTipo
from ALQ_Alquiler as aa
join ALQ_Coche as ac
on ac.Matricula = aa.Matricula
join ALQ_tipoCoche as tc
on tc.CodTipo = ac.codTipo
group by aa.Matricula, DescripcionTipo
order by [Nalquileres vehiculo] desc
go

-- otra manera mediante subconsultas

select 
	count(*) as 'Nalquileres vehiculo',
	aa.Matricula,
	(select DescripcionTipo from ALQ_tipoCoche as tc where tc.CodTipo =
		(select ac.codTipo from ALQ_Coche as ac where ac.Matricula = aa.Matricula)) as 'Descripcion Tipo'
from ALQ_Alquiler as aa
group by aa.Matricula
order by [Nalquileres vehiculo] desc
go

--3.- Indicar cu�ntos coches hay en la empresa, y cu�ntos de ellos se han alquilado alguna vez en 2011

select
	distinct(count(Matricula)) as 'ncoches'
from ALQ_Coche
go

select
	count(distinct(ac.Matricula)) as 'ncoches'
from ALQ_Coche as ac
where ac.Matricula in (select Matricula from ALQ_Alquiler where YEAR(FechaInicio) = 2011)
go

select
	count(distinct(ac.Matricula)) as 'ncoches'
from ALQ_Coche as ac
join ALQ_Alquiler as aa
on aa.Matricula = ac.Matricula
where year(FechaInicio) = 2011
go

--4.- Mostrar los alquileres realizados en sabado o domingo y cuya duraci�n fue superior o igual a tres d�as. Indicando la matricula, los d�as de alquiler y el nombre del cliente

select
	aa.DNICliente,
	aa.Matricula, 
	(select Nombre from ALQ_Cliente as ac where ac.DNICliente = aa.DNICliente) as 'Nombre Cliente',
	datediff(day, FechaInicio, FechaFinal) as 'ndias alquiler'
from ALQ_Alquiler as aa
where day(aa.FechaInicio) in (6,7) and DATEDIFF(day, FechaInicio, FechaFinal) >= 3
go

select
	aa.DNICliente,
	aa.Matricula,
	ac.Nombre,
	datediff(day, FechaInicio, FechaFinal) as 'ndias alquiler'
from ALQ_Alquiler as aa
join ALQ_Cliente as ac
on ac.DNICliente = aa.DNICliente
where day(aa.FechaInicio) in (6,7) and DATEDIFF(day, FechaInicio, FechaFinal) >= 3
go

--5.- Mostrar nombre y antig�edad del carnet del mejor cliente de 2011, 
-- indicar el n�mero de alquileres y el dinero gastado en nuestro negocio en ese a�o

select
	Nombre,
	aa.DNICliente,
	DATEDIFF(year, FechaCarnet,GETDATE()) as 'Antiguedad del carnet',
	sum(DATEDIFF(day, FechaInicio, FechaFinal) * PrecioDiaEfectuado) as 'Dinero gastado'
from ALQ_Cliente as ac
join ALQ_Alquiler as aa
on ac.DNICliente = aa.DNICliente
where year(FechaInicio) = 2011
group by ac.Nombre, aa.DNICliente, ac.FechaCarnet
order by [Dinero gastado]
go

--6.- Nombre de los clientes que nunca han alquilado coches. Utilizar join. 

select 
	Nombre,
	DNICliente
from ALQ_Cliente
where DNICliente not in (select DNICliente from ALQ_Alquiler)
go

select 
	Nombre,
	DNICliente
from ALQ_Cliente as ac
where not exists (
	select DNICliente 
	from ALQ_Alquiler as aa 
	where ac.DNICliente = aa.DNICliente
)
go

select 
	Nombre,
	ac.DNICliente
from ALQ_Cliente as ac
left join ALQ_Alquiler as aa
on ac.DNICliente = aa.DNICliente
where aa.DNICliente is null
go


--7.- Nombre de los clientes que no han alquilado coches en el mes actual. Utilizar subconsulta.

select 
	Nombre,
	DNICliente
from ALQ_Cliente as ac
where DNICliente not in (
	select DNICliente 
	from ALQ_Alquiler 
	where month(FechaInicio) = month(getdate())
)
go

select 
	Nombre,
	ac.DNICliente, 
	FechaInicio
from ALQ_Cliente as ac
left join ALQ_Alquiler as aa
on ac.DNICliente = aa.DNICliente
where month(FechaInicio) != month(getdate())
go

--8.- Nombre de los clientes, que han alquilado el 3216-BHF en 2011. Utilizar exists y campos correlacionados.

select 
	Nombre
from ALQ_Cliente as ac
where exists(
	select aa.DNICliente 
	from ALQ_Alquiler as aa 
	where Matricula = '3216-BHF' and year(FechaInicio) = 2011 and aa.DNICliente = ac.DNICliente
)
go

-- otra manera m�s sencilla con join

select 
	Nombre,
	aa.Matricula
from ALQ_Cliente as ac
join ALQ_Alquiler as aa
on aa.DNICliente = ac.DNICliente
where Matricula = '3216-BHF' and year(FechaInicio) = 2011
go

-- mediante subconsulta que devuelve valor 				
			
select 
	Nombre
from ALQ_Cliente as ac
where ac.DNICliente in(
	select DNICliente 
	from ALQ_Alquiler as aa 
	where Matricula = '3216-BHF' and year(FechaInicio) = 2011
)
go						
					
								

