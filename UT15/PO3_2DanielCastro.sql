if db_id('BD_Trigger') is null create database BD_Trigger;
go
use BD_Trigger;
go

-- ################ Ejercicio_4   DISPARADORES ##########################################
-- Una empresa almacena los datos de sus empleados en una tabla denominada "empleados" y
-- los datos de las distintas sucursales en una tabla "sucursales". Los empleados trabajan en "una sección"

if object_id('empleados') is not null
drop table empleados;
if object_id('sucursales') is not null
drop table sucursales;
if object_id('secciones') is not null
drop table secciones;

-- crear las tablas, con las siguientes estructuras:
create table sucursales(
codigo int identity,
domicilio varchar(30),
constraint PK_sucursales primary key (codigo)
);

create table secciones(
codigo int identity,
nombre varchar(30),
sueldomaximo decimal(8,2),
constraint PK_secciones primary key(codigo)
);
create table empleados(
nif char(9) not null,
nombre varchar(30),
domicilio varchar(30),
sucursal int not null,
codigoseccion int not null,
sueldo decimal(8,2),

constraint PK_empleados primary key (nif),
constraint FK_empleados_sucursal foreign key(sucursal)
	references sucursales(codigo),
constraint FK_empleados_seccion foreign key (codigoseccion) 
	references secciones(codigo)
);


-- Se ingresaron algunos registros en las tres tablas:
insert into sucursales values ('Colon 123');
insert into sucursales values ('Sucre 234');
insert into sucursales values ('Rivadavia 345');

insert into secciones values('Administracion',1500);
insert into secciones values('Sistemas',2000);
insert into secciones values('Secretaria',1000);

insert into empleados values ('22222222A','Ana Acosta','Avellaneda 1258',1,2,1600);
insert into empleados values ('23333333A','Betina Bustos','Bulnes 345',2,2,1000);
insert into empleados values ('24444444A','Carlos Caseres','Caseros 948',3,1,1100);
insert into empleados values ('25555555A','Fabian Fuentes','Francia 845',1,3,1000);
insert into empleados values ('26666666A','Gustavo Garcia','Guemes 587',2,2,1800);
insert into empleados values ('27777777A','Maria Morales','Maipu 643',3,1,1400);
go

-- ################# Ejerc_1 #########################################
--  Cree un disparador de inserción, eliminación y actualización que no permita modificaciones
-- en la tabla "empleados" si tales modificaciones afectan a empleados de la sucursal 1.
if OBJECT_ID('tr_empleadosIns') is not null
drop trigger tr_empleadosIns
go
create trigger tr_empleadosIns
on empleados
for insert
as
	declare @sucursal as int
	select @sucursal = sucursal from inserted
	if (@sucursal = 1)
	begin
		raiserror('No pueden insertarse empleados de la sucursal 1', 10, 1)
		rollback transaction
	end
go

if OBJECT_ID('tr_empleadosUpd') is not null
drop trigger tr_empleadosUpd
go
create trigger tr_empleadosUpd
on empleados
for update
as
	if update(sucursal)
	begin
		raiserror('No se puede actualizar la sucursal de los empleados', 10, 1)
		rollback transaction
	end
go

if OBJECT_ID('tr_empleadosDel') is not null
drop trigger tr_empleadosDel
go
create trigger tr_empleadosDel
on empleados
for delete
as
	declare @sucursal as int
	select @sucursal = sucursal from deleted
	if (@sucursal = 1)
	begin
		raiserror('No pueden borrarse empleados de la sucursal 1', 10, 1)
		rollback transaction
	end
go



-- pruebas
--1a- Ingrese un empleado en la sucursal 3.
-- El trigger se dispara permitiendo la transacción;
insert into empleados values ('27778777G','Mario Morales','Kaika 543',3,1,1400);
go



--1b- Intente ingresar un empleado en la sucursal 1.
-- El trigger se dispara y deshace la transacción.
insert into empleados values ('27787779L','Marta Cano','Vati 685',1,1,1400);
go



--1c- Ejecute una actualización sobre "empleados" que permita la transacción.
update empleados set codigoseccion = 2 where nif like '27778777G'



--1d- Ejecute una actualización sobre "empleados" que el trigger deshaga.
update empleados set sucursal = 2 where nif like '27778777G'



--1e- Elimine un empleado (o varios) que no sean de la sucursal 1.
--El trigger se ejecuta y la transacción se realiza.
delete empleados where nif like '27778777G' 



--1f- Intente eliminar un empleado (o varios) de la sucursal 1.
-- El trigger deshace la transacción.
delete empleados where nif like '22222222A'



-- ################# Ejerc_2 #########################################
-- Realiza un trigger que evite que se le asigne a un empleado
-- un sueldo mayor al máximo de su sección 
if OBJECT_ID('tr_sueldoMax') is not null
drop trigger tr_sueldoMax
go
create trigger tr_sueldoMax
on empleados
for insert
as
	declare @seccionEmpleado as int
	select @seccionEmpleado =
		codigoseccion
		from empleados
	declare @sueldoMax as decimal(8,2)
	select @sueldoMax = 
		sueldomaximo 
		from secciones 
		where secciones.codigo = @seccionEmpleado
	declare @sueldoEmpleado as decimal(8,2)
	select @sueldoEmpleado =
		sueldo
		from empleados
	if @sueldoEmpleado > @sueldoMax
	begin
		raiserror('El sueldo del empleado es mayor que el de la sección', 10, 1)
		rollback transaction
	end
go



-- diseña unas pruebas, que demuestren que el disparador funciona
--El sueldo es mayor que el máximo
insert into empleados values ('27785579L','Antonio Lobato','Vati 685',2,2,3000);
go
--El sueldo es menor que el máximo
insert into empleados values ('27788679L','Musaraña Atento','Valdes 245',2,2,800);
go



-- ################# Ejerc_3 #########################################
-- Realiza una función a la que le pases el nº de sucursal y un patron de sección
-- y devuelva una tabla que indique NIF, nombre y apellidos, la sección y el sueldo
-- de los empleados que trabajen en esa sección y la sucursal pasada
if OBJECT_ID('f_InfoEmpleado') is not null
drop function f_InfoEmpleado
go
create function f_InfoEmpleado
(@sucursal int, @patron varchar(30))
returns table
as
return
(
	select 
		nif as 'NIF', 
		nombre as 'Nombre y Apellidos',
		codigoseccion as 'Codigo Seccion',
		sueldo as 'Sueldo'
	from empleados
	where codigoseccion in (
		select codigo
		from secciones 
		where nombre like @patron
		)
	and sucursal = @sucursal
)
go



--prueba de ejecución
select * from f_InfoEmpleado (1,'%')
select * from f_InfoEmpleado (1,'Adm%')
select * from f_InfoEmpleado (1,'S%')
go

-- ################# Ejerc_4 #########################################
-- Realiza una función a la que le pases el el nº la sucursal y un patron de sección
-- y utilizando la función anterior devuelva una cadena con los NIF de los empleados 
-- con mayor sueldo separados por '&'
if OBJECT_ID('f_mayorSueldo') is not null
drop function f_mayorSueldo
go
create function f_mayorSueldo
(@sucursal int, @patron varchar(30))
returns varchar(100)
as 
begin
	return 
		(
		select top 1 with ties 
		string_agg(nif,'&') 
		from f_InfoEmpleado (@sucursal, @patron)
		group by [Sueldo]
		order by [Sueldo]
		)
end
go

--cadena y separador
-- haz una prueba de ejecución

print dbo.f_mayorSueldo(1, '%')