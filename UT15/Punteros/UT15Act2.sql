use tenis
go

declare @torneo as varchar(50)
declare @numEd as tinyint
declare @numJug as tinyint
declare @fecha as date
declare @c as tinyint
declare @ganadores as varchar(50)
declare @edicionesGanadas as tinyint

declare CUR cursor for

select 
	Torneo,
	COUNT(et.id) as 'Nº Ediciones', 
	Njugadores
from EdicionTorneo as et
join Torneo as t
on t.IdTorneo = et.IdTorneo
where IdPais = 27
group by Torneo, Njugadores
order by Torneo, Njugadores

declare CUR2 cursor for

select
	Fecha
from EdicionTorneo as et
join Torneo as t
on t.IdTorneo = et.IdTorneo
where IdPais = 27
order by Torneo asc

declare CUR3 cursor for

select 
	Jugador as Ganador,
	COUNT(Ganador) as 'Num Victorias'
from EdicionTorneo as et
join Jugador as j
on et.Ganador = j.IdJugador
join Torneo as t
on t.IdTorneo = et.IdTorneo
where IdPais = 27
group by t.Torneo, Jugador
order by t.torneo, COUNT(Ganador) desc, Jugador

set @c = 0
set nocount on

print char(13)
print '###### LISTADO DE EQUIPOS #############'
print '______________________________________'
print char(13)

open CUR
open CUR2
open CUR3

fetch next from CUR
	into @torneo, @numEd, @numJug
while (@@FETCH_STATUS = 0)
	begin
		print @torneo + char(13)
		print 'Ediciones: ' + cast(@numEd as varchar)
		print 'Fecha de las ediciones: '

		while (@c < @numEd)
			begin
				fetch next from CUR2 into @fecha
				print cast(@fecha as varchar(40)) + ''
				set @c += 1
			end

		print char(13)
		print cast(@numJug as varchar) + ' participantes en última edición'

		fetch next from CUR3 into @ganadores, @edicionesGanadas
			print 'El jugador que más veces ha ganado el torneo es: ' + cast(@ganadores as varchar(30)) + ' INCORRECTO'

		print char(13)
		print '______________________________________'
		print char(13)
		set @c = 0

		fetch next from CUR
			into @torneo, @numEd, @numJug
	end

close CUR3
deallocate CUR3

close CUR2
deallocate CUR2

close CUR
deallocate CUR
go


select
	*
from EdicionTorneo as et
join Torneo as t
on t.IdTorneo = et.IdTorneo
where IdPais = 27
order by Torneo
