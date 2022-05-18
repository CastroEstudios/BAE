use tenis
go

if OBJECT_ID('dbo.f_tenisGanador') is not null
drop function dbo.f_tenisGanador
go

create function dbo.f_tenisGanador
	(@nomJugador varchar(30))
	returns varchar(150)
	as
	begin
	
		declare @idJugador smallint = (
			select 
			IdJugador
		from Jugador
		where Jugador like @nomJugador
		)

		declare @nomEnteroJugador varchar(40) = (
			select
				Jugador
			from Jugador
			where IdJugador = @idJugador
		)
		declare @edicionesGanadas tinyint = (
			select
				COUNT(id)
			from EdicionTorneo
			where Ganador = @idJugador
		)
		declare @sentencia varchar(150) = 
			'Nombre: ' + @nomEnteroJugador + ', ediciones ganadas: ' + cast(@edicionesGanadas as varchar(2))
		return @sentencia
	end
go

print dbo.f_tenisGanador('%Nadal%')


-------------------------------------------------------------------------------------------

use tenis
go

if OBJECT_ID('dbo.f_tenisGanador') is not null
drop function dbo.f_tenisGanador
go

create function dbo.f_tenisGanador
	(@idJugador smallint)
	returns varchar(150)
	as
	begin

		declare @nomEnteroJugador varchar(40) = (
			select
				Jugador
			from Jugador
			where IdJugador = @idJugador
		)

		declare @edicionesGanadas tinyint = (
			select
				COUNT(id)
			from EdicionTorneo
			where Ganador = @idJugador
		)
		
		declare @idEdicionesGanadas varchar(100)
		declare CUR cursor for 
			select 
				id
			from EdicionTorneo
			where Ganador = @idJugador

		open CUR

		fetch next from CUR into @idEdicionesGanadas

		while (@@FETCH_STATUS = 0)
			begin
				declare @totalEdiciones varchar(200)
				set @totalEdiciones += @idEdicionesGanadas --@totalEdiciones se cierra antes de @sentcia?
				fetch next from CUR into @idEdicionesGanadas
			end
		close CUR
		deallocate CUR

		declare @sentencia varchar(150) = 
			'Nombre: ' + @nomEnteroJugador + ', número ediciones ganadas: ' + cast(@edicionesGanadas as varchar(2))
			+ char(13) + @totalEdiciones
		return @sentencia
	end
go

print dbo.f_tenisGanador(2)