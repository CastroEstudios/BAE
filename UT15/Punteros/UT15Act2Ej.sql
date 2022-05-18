use tenis
go

declare @nombreTorneo varchar(100),
@fechaTorneo datetime, 
@nombreJugador varchar(100),
@c tinyint

declare c_Tenis cursor for
	select distinct
		Torneo,
		Fecha,
		Jugador
	from EdicionTorneo as et
	join Torneo as t
	on et.IdTorneo = t.IdTorneo
	join Jugador as j
	on j.IdJugador = et.Ganador
	where IdPais = 27
	group by Torneo
	order by Torneo

open c_Tenis
print 'GANADORES TORNEOS ESPANOLES'
print '--------------------------------------'
fetch next from c_Tenis 
into @nombreTorneo, @fechaTorneo, @nombreJugador
set @c = 0
while (@@FETCH_STATUS=0)
begin

	if @nombreJugador like '%Nadal'
		begin
			set @c += 1
			set @nombreJugador = 'NADAL'
		end

	print 'Torneo: ' + @nombreTorneo
	print 'Fecha: ' + cast(@fechaTorneo as varchar(100))
	print 'Nombre Ganador: ' + @nombreJugador
	print '--------------------------------------'
	
	fetch next from c_Tenis 
	into @nombreTorneo, @fechaTorneo, @nombreJugador
end
print 'Nadal ha ganado ' + cast(@c as varchar(2)) + ' torneos'
close c_Tenis
deallocate c_Tenis