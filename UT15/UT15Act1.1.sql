create procedure pa_Saluda as
	print 'hola'
	delete mi_table
go

exec pa_Saluda
print @@error
go

begin try
	drop procedure spu_Saluda
end try
begin catch
	print 'No se ha podido borrar el procedimiento'
end catch
go

create database procedimientos
go

create table prueba
(dato1 integer, dato2 varchar(30))
go

create procedure VerTablaExtra @valor integer
as
	select dato2 from prueba
	where dato2 = @valor
go
exec VerTablaExtra 
go



use procedimientos
go

insert into prueba(dato1, dato2)
values (2, 'Siow')
go

if OBJECT_ID('VerTablaExtra2') is not null
drop procedure VerTablaExtra2
 go
create procedure VerTablaExtra2 
	@valor integer,
	@resultado integer output
as
	select dato1, dato2 from prueba
	where dato1 = @valor
	set @resultado = @@ROWCOUNT
go



declare @n integer
exec VerTablaExtra2 @valor = 2, @resultado=@n output
print @n
go

--------------------------------------------------

use procedimientos
go

if OBJECT_ID('libros') is not null
drop table libros
go

create table libros (
	titulo varchar(30),
	autor varchar(30),
	editorial varchar(18),
	precio decimal (6,2)
)
go

insert into libros
values('Jarri Porter', 'J.K.Roulin', 'IPhone', 63.15)
insert into libros
values('Jarri Porter', 'J.K.Roulin', 'IPhone', 63.15)
insert into libros
values('Jarri Porter', 'A.K.Roulin', 'IPhone', 3.15)
go

if OBJECT_ID('pa_autor_MaxPVP_Promedio') is not null
drop procedure dbo.pa_autor_MaxPVP_Promedio
go

create procedure pa_autor_MaxPVP_Promedio
 @autor varchar(30)='%',
 @MaxPVP decimal(6,2) output, @promedio decimal(6,2) output,
 @valoracion char(2)='' output
 as
 select titulo,editorial,precio from libros where autor like @autor
 set @MaxPVP=(select max(precio) from libros where autor like @autor)
 set @promedio=(select avg(precio) from libros where autor like @autor)
 If @promedio>40 set @valoracion='Sí';
 if @promedio<=40 set @valoracion='No';
go

declare @j decimal(6,2)
declare @n decimal(6,2)
declare @m char(2)
exec pa_autor_MaxPVP_Promedio @autor = 'A%', @MaxPVP = @j output, @promedio = @n output, @valoracion = @m output
print 'El libro mas caro cuesta: ' + cast(@j as varchar) + '€'
print 'El PVP medio es ' + cast(@n as varchar) + '€' 
print '¿Son caros los libros? -' + cast(@m as varchar)
go