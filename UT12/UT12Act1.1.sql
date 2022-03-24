--Práctica UT 12  

--1. Crear la Base de datos Empresa en la carpeta DATA de tu Instancia, con tamaño inicial 
--para datos de 4MB, tamaño mayor 20 MB e incrementos 2MB. y fichero de 
--registro con los parámetros:
--	 size = 2MB,maxsize = 10MB, filegrowth = 1MB

use master
go

if DB_ID('Empresa') is not null
drop database Empresa
go

create database Empresa
on 
(	name = Empresa_dat,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESSDDL12\MSSQL\DATA\Empresa.mdf',
	size = 4MB,
	maxsize = 25MB,
	filegrowth = 2MB )
log on
(	name = Empresa_log,
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESSDDL12\MSSQL\DATA\Empresa_log.ldf',
	size = 2MB,
	maxsize = 10MB,
	filegrowth = 1MB );
go

use Empresa
go

set dateformat dmy
go

--2. Crear una tabla Empleados con la estructura siguiente:
-- ( DNI varchar(9), nombre varchar(30), apellidos varchar(30), 
--fechanacimiento date, fechaingreso date numhijos tinyint, 
--seccion (A,B o C), sueldo decimal(6,2) , añosAntigüedad como campo calculado)

if OBJECT_ID('Empleados') is not null
drop table Empleados
go

create table Empleados
	(DNI char(9),
	Nombre varchar(30),
	Apellidos varchar(30),
	FechaNacimiento date,
	FechaIngreso date,
	NumHijos tinyint,
	Seccion char(1),
	Sueldo decimal(6,2),
	AgnosAntiguedad as FLOOR(DATEDIFF(DAY, FechaIngreso, getdate()) / 365.25)
	)
go

--3. Crear las sentencias para que valide lo siguiente:
--	a. clave primaria DNI
--	b. no nulo apellidos
--	c. no nulo nombre
--	d. valor único apellidos y nombre
--	e. validar que:
--		fechanacimiento sea menor que la fecha actual
--		fechaingreso no permita trabajar sin cumplir 16 años
--	f. validar que cantidad de hijos no sea negativa ni mayor que 10
--	g. validar que sección no esté vacío, acepte solo A,B o C y por defecto A

alter table Empleados
	alter column DNI char(9) not null
go

alter table Empleados
	add primary key (DNI)
go

alter table Empleados
	alter column Apellidos varchar(30) not null
go

alter table Empleados
	alter column Nombre varchar(30) not null
go

alter table Empleados
	add constraint uq_ApellidoNombre
		unique(Apellidos, Nombre)
go

alter table Empleados
	add constraint ck_FechaNacMenor
		check(FechaNacimiento < getdate())
go

alter table Empleados
	add constraint ck_FechaIngresoMayor16
		check(FechaIngreso > FLOOR(DATEDIFF(DAY, FechaNacimiento, getdate()) / 365.25))
go

alter table Empleados
	add constraint ck_NumHijos
		check(NumHijos >= 0 and NumHijos <= 10)
go

alter table Empleados
	alter column Seccion char(1) not null
go

alter table Empleados
	add constraint ck_ValorSeccion
		check(Seccion in ('A','B','C'))
go


--4. Comprobar que índices tiene la tabla Empleado y de que tipo son.

exec sp_helpindex Empleados;
go

--5. Añadir índice por apellido+nombre

create nonclustered index ix_ApellidosNombre
on Empleados(Apellidos, Nombre)
go

--6.  Ingresar 3 empleados en cada sección, cumplimentando sólo los datos obligatorios

insert into Empleados (DNI, Nombre, Apellidos, Seccion)
	values ('44444444W', 'Jose', 'Luis Ramos', 'A')
go

insert into Empleados (DNI, Nombre, Apellidos, Seccion)
	values ('44445462W', 'Josue', 'Castro Hernandez', 'B')
go

insert into Empleados (DNI, Nombre, Apellidos, Seccion)
	values ('44445862W', 'Josepe', 'Montesinos Alonso', 'C')
go

--7. Modificar lo siguiente en la tabla
--	a. Añadir campo Iniciales en mayúscula inicial nombreInicial apellido primero
--		ejemplo: LC para Lucinio Cordero

alter table Empleados
	add Iniciales as concat(upper(left(Nombre, 1)), upper(left(Apellidos, 1)))
go

--	b. Cambiar numhijos para que tenga que cumplimentarse obligatoriamente, por defecto 0
	
update Empleados
	set NumHijos = ''
	where NumHijos is null
go

alter table Empleados
	alter column NumHijos tinyint not null
go

alter table Empleados
	drop constraint ck_NumHijos
go

alter table Empleados
	add constraint ck_NumHijos 
		check(NumHijos >= 0 and NumHijos <= 10),
		default 0 for NumHijos
go

--	c. Validar para que sueldo sea mayor que 680  y menor que 3500	
	
alter table Empleados
	add constraint ck_RangoSueldo
		check(Sueldo > 680 and Sueldo < 3500)
go

--	d.  Eliminar la columna sueldo

alter table Empleados
	drop constraint ck_RangoSueldo
go

alter table Empleados
	drop column Sueldo
go

--8. Añadir indice por campo Iniciales

create nonclustered index ix_Iniciales
on Empleados(Iniciales)
go

--9.  Crear las Vistas siguientes;

--	EmpleadosSeccionA: indicando Iniciales, nombre+apellidos, trienios y sueldo

alter table Empleados
	add Sueldo decimal(6,2)
go

if OBJECT_ID('EmpleadosSeccionA', 'V') is not null
drop view EmpleadosSeccionA
go

create view EmpleadosSeccionA
as
select 
	Iniciales,
	concat(Nombre, ' ', Apellidos) as 'Nombre + Apellidos',
	(AgnosAntiguedad - 3) as 'Trienios',
	Sueldo
from Empleados
go

select *
from EmpleadosSeccionA
go

--	EmpladosFamNumerosa: indicando nombre+apellidos, seccion, fechaingreso, numhijos >=3,

insert into Empleados (DNI, Nombre, Apellidos, Seccion, NumHijos)
	values ('83757329F', 'Mario', 'Castaño Montillas', 'B', '5')
go

if OBJECT_ID('EmpleadosFamNumerosa','V') is not null
	drop view EmpleadosFamNumerosa
go

create view EmpleadosFamNumerosa
as
select 
	concat(Nombre, ' ', Apellidos) as 'Nombre + Apellidos',
	Seccion,
	FechaIngreso,
	NumHijos
from Empleados
where NumHijos >= 3
go

select *
	from EmpleadosFamNumerosa
go

--10. utilizando la última vista, dar listado de empleados con familianumerosa 
--ordenados por numhijos, que lleven más de 5 años en la empresa.

select
	[Nombre + Apellidos]
from EmpleadosFamNumerosa as EFN
order by NumHijos desc
go

--No tengo claro como hacerla, hay que hacer join supongo, pero no tengo donde hacer el join.