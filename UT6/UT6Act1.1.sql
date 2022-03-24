
use master
if DB_ID('tarea6_1') is not null
drop database tarea6_1
go

set DATEFORMAT dmy;
go

create database tarea6_1
go
use tarea6_1
go



if OBJECT_ID('SOCIO') is not null
drop table SOCIO
go

create table SOCIO(
	NIF varchar(11) primary key,
	Email varchar(30),
	Fecha_alta datetime default getdate(),
	Fecha_carnet date,
	Telefono varchar(12),
	Direccion varchar(45)
)
go



if OBJECT_ID('TIPOVEHICULO') is not null
drop table TIPOVEHICULO
go

create table TIPOVEHICULO(
	IdCategoria char(1) CHECK(IdCategoria IN ('A', 'B', 'C')) primary key,
	Descripcion varchar(45),
	NumPlazas tinyint,
	PrecioDia decimal(5,2) 
)
go



if OBJECT_ID('VEHICULO') is not null
drop table VEHICULO
go

create table VEHICULO(
	Matricula varchar(8) primary key,
	Marca varchar(20),
	Modelo varchar(20),
	TIPOVEHICULO_IdCategoria char(1) references TIPOVEHICULO(IdCategoria)
)
go



if OBJECT_ID('EMPOFI') is not null
drop table EMPOFI
go

create table EMPOFI(
	Nombre varchar(20) primary key,
	Turno varchar(1)
)
go



if OBJECT_ID ('ALQUILER') is not null
drop table ALQUILER
go

create table ALQUILER(
	IdAlquiler int primary key,
	SOCIO_NIF varchar(11) references SOCIO(NIF),
	EMPOFI_Nombre varchar(20) references EMPOFI(Nombre),
	VEHICULO_Matricula varchar(8) references VEHICULO(Matricula)
)
go



if OBJECT_ID('COLOR') is not null
drop table COLOR
go

create table COLOR(
	VEHICULO_Matricula varchar(8) references VEHICULO(Matricula),
	Color varchar(10),
	primary key(VEHICULO_Matricula, Color)
)
go



if OBJECT_ID('PLAZA') is not null
drop table PLAZA
go

create table PLAZA(
	Plaza_ID tinyint,
	Planta_ID tinyint,
	Estado varchar(45),
	primary key(Plaza_ID, Planta_ID)
)
go



if OBJECT_ID('ESTACIONAMIENTO') is not null
drop table ESTACIONAMIENTO
go

create table ESTACIONAMIENTO(
	Fecha_devolucion datetime default getdate(),
	Fecha_inicio datetime default getdate(),
	VEHICULO_Matricula varchar(8) references VEHICULO(Matricula),
	Planta tinyint,
	Plaza tinyint,
	foreign key (Plaza,Planta) references Plaza(Plaza_ID,Planta_ID),
	primary key (Fecha, VEHICULO_MATRICULA)
)
go



--1.

insert into VEHICULO(Marca, Modelo, Matricula)
values ('VW', 'Pasat 2,0TDI', '6677FTS')
insert into COLOR(VEHICULO_Matricula, Color)
values ('6677FTS', 'GrisNegro')
insert into TIPOVEHICULO(IdCategoria)
values ('B')
insert into PLAZA(Planta_ID, Plaza_ID)
values (3,10)
go

insert into VEHICULO(Marca, Modelo, Matricula)
values ('Alfa Romeo', '156TS', 'TF8010BM')
insert into COLOR(VEHICULO_Matricula, Color)
values ('TF8010BM', 'Rojo')
insert into TIPOVEHICULO(IdCategoria)
values ('B')
insert into PLAZA(Planta_ID, Plaza_ID)
values (3,8)
go

insert into VEHICULO(Marca, Modelo, Matricula)
values ('Audi', 'A6 3.0 TDI', '9876KKJ')
insert into COLOR(VEHICULO_Matricula, Color)
values ('9876KKJ', 'Verde')
insert into PLAZA(Planta_ID, Plaza_ID)
values (3,9)
go



--3.

insert into SOCIO(NIF, Fecha_carnet)
values ('42000000A','01/01/1999')
go



--4

if OBJECT_ID ('ALQUILER') is not null
drop table ALQUILER
go

create table ALQUILER(
	IdAlquiler int identity primary key,
	SOCIO_NIF varchar(11) references SOCIO(NIF),
	EMPOFI_Nombre varchar(20) references EMPOFI(Nombre),
	VEHICULO_Matricula varchar(8) references VEHICULO(Matricula)
)
go



--5

insert into EMPOFI(Nombre, Turno)
values ('Jose', 'M')
go
insert SOCIO(NIF)
values ('42000000A')
insert EMPOFI(Nombre)
values ('Jose')
insert ESTACIONAMIENTO(VEHICULO_Matricula,Fecha_devolucion) 
values ('TF8010BM','03/11/2019 12:30')
go



--6

select Planta,	Plaza
from Estacionamiento
where VEHICULO_Matricula='TF8010BM'
go



--7

update ESTACIONAMIENTO
set Fecha_devolucion='02/11/2019 10:00'
where VEHICULO_Matricula='TF8010BM'
go



--8

update ESTACIONAMIENTO
set Planta=2, Plaza=7
where VEHICULO_Matricula='TF8010BM'
go



select * from VEHICULO
select * from COLOR
select * from TIPOVEHICULO
select * from PLAZA
select * from SOCIO
go

--CREATE TABLE Customer
--(
--    Gender CHAR(1) CHECK(Gender IN ('M', 'F'))
--); 
--
--INSERT INTO Customer (Gender) VALUES('M');
--INSERT INTO Customer (Gender) VALUES('F');

--INSERT INTO Customer (Gender) VALUES('A');
