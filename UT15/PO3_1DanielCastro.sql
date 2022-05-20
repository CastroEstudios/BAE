-- PO 3.1  1ºB DAM  20/05/2022	tiempo 2h
--Daniel Castro Cruz

use ciclismo
go
-- realizar en BD la actualización siguiente
update EquipoCampeonato
set Nparticipantes=16 
where idcampeonato=154 and idequipo=394
go

--Se pide: hacer un proc. almacenado pa_Inf_Club
-- al que le pasas el id de un club, por defecto el que corresponda al club  'ARANDINO, C.C.'
-- el procedimiento comprueba que existe el club, y de ser asi, muestra la información siguiente:
--1)  NOMBRE DEL CLUB y FEDERACIÓN a la que pertenece
--2)  nombre de los campeonatos en los que ha participado algún equipo del club,
--    indicando el premio y el organizador, ordenados por premio descendente 

 
-- el procedimiento, devuelve además tres parametros:
--p1 el número de ciclistas inscritos en ese club
--p2 el nombre de todos los equipos del club pasado, separados por ' & '

--p3 el nombre del campeonato con mayor número de participantes de ese club y organizador del o los mismos
-- ojo!!!! puede haber empates. Puedes utilizar la función dbo.f_Partic_Club





if object_id('dbo.f_Partic_Club') is not null drop function dbo.f_Partic_Club
go
create function dbo.f_Partic_Club( @id int)
returns table
as 
	return (select idcampeonato, idequipo, nparticipantes 
			from equipocampeonato 
			where idequipo=any(select idequipo from equipo where idclub=@Id));
go


-- prueba
select * from dbo.f_Partic_Club(30)
go




-- ##################  Solución al procedimiento  ###########################

SELECT
	idClub
FROM Club
WHERE Club like 'ARANDINO, C.C.'
go

if object_id('dbo.pa_Inf_Club','P') is not null 
drop procedure dbo.pa_Inf_Club
go

create procedure dbo.pa_Inf_Club
@id int = 30,
@numCiclistas smallint output,
@nomEquipos varchar(200) output,
@nomCampeonato varchar(40) output
as
	set nocount on
	set @nomEquipos = ''

	if (
		select
			Club
		from Club
		where idClub = @id
	) is null 
	begin
		print 'Introduzca un id de club válido'
		return
	end

	select 
		Club,
		Federacion
	from Club as c
	join Federacion as f
	on c.IdFederacion = f.Id
	where idClub = @id

	select
		Campeonato,
		c.Premios,
		c.IdOrganizador
	from Campeonato as c
	join EquipoCampeonato as ec
	on c.Id = ec.idcampeonato
	where ec.idequipo in (
		select 
			e.IdEquipo
		from Club as c
		join Equipo as e
		on c.idClub = e.IdClub
		where c.idClub = @id
	)
	order by c.Premios desc

	set @numCiclistas = (
		select
			sum(NCiclistas) as 'Ciclistas totales'
		from Equipo
		where IdClub = @id
	)

	declare @nomEquiposCur as varchar(40)
	declare equiposCur cursor for 
		select
			Nombre
		from Equipo
		where IdClub = @id

	open equiposCur
	fetch next from equiposCur into @nomEquiposCur
	while (@@FETCH_STATUS = 0)
		begin
			set @nomEquipos += @nomEquiposCur + ' & '
			fetch next from equiposCur into @nomEquiposCur
		end
	close equiposCur
	deallocate equiposCur

	set @nomCampeonato = (
	select top 1
		Campeonato
	from Campeonato as c
	join EquipoCampeonato as ec
	on c.Id = ec.idcampeonato
	join Equipo as e
	on ec.idequipo = e.IdEquipo
	where IdClub = @id
	order by Nparticipantes desc
	)

	set @nomCampeonato += ', ' + cast((
	select top 1
		IdOrganizador
	from Campeonato as c
	join EquipoCampeonato as ec
	on c.Id = ec.idcampeonato
	join Equipo as e
	on ec.idequipo = e.IdEquipo
	where IdClub = @id
	order by Nparticipantes desc
	) as varchar(50))

go

-- hacer prueba de ejecución
declare @numCiclistas as smallint
declare @nomEquipos as varchar(200)
declare @nomCampeonato as varchar(40)
exec dbo.pa_Inf_Club 30, @numCiclistas output, @nomEquipos output, @nomCampeonato output
print 'ciclistas inscritos en el club: ' + cast(@numCiclistas as varchar(40))
print 'equipos del club: ' + @nomEquipos
print 'campeonato/s al que el club envió más ciclistas: ' + @nomCampeonato + ('(id organizador)')
go









--ANEXOS
-- club con más equipos
select top 1 with ties
	idclub,
	(select club from club where idClub=equipo.IdClub) as CLUB
from equipo 
group by idclub
order by count(idequipo) desc









