--DISPARADORES O TRIGGER
if db_id('BD_Trigger') is null create database BD_Trigger;
go
use BD_Trigger;
go

-- ################### Ejerc 1 ##############################################
-- Un club almacena datos de sus socios en una tabla "socios", 
-- y los datos de las inscripciones en una tabla denominada "inscritos" 
-- y en una tabla "morosos" almacena el nif de los socios inscritos que deben matrícula.


-- 1- Elimine las tablas si existen:
if object_id('inscritos') is not null drop table inscritos;
if object_id('socios') is not null drop table socios;
if object_id('morosos') is not null drop table morosos;
go

-- 2- Cree las tablas, con las siguientes estructuras:
create table socios(
nif char(9) not null,
nombre varchar(30),
domicilio varchar(30),
constraint PK_socios primary key (nif)
);
create table inscritos(
nif char(9) not null,
deporte varchar(30) not null,
matricula char(1),
constraint CK_inscritos check (matricula in ('s','n')),
constraint PK_inscritos primary key (nif,deporte),
constraint FK_inscritos_nif foreign key(nif) references socios (nif)
);
create table morosos(
nif char(9) not null
);
go

-- 3- Ingrese algunos registros en las tres tablas:
insert into socios values ('22222222M','Ana Acosta','Avellaneda 800');
insert into socios values ('23333333M','Bernardo Bustos','Bulnes 234');
insert into socios values ('24444444A','Carlos Caseros','Colon 321');
insert into socios values ('25555555A','Mariana Morales','Maipu 483');

insert into inscritos values ('22222222M','tenis','s');
insert into inscritos values ('22222222M','natacion','n');
insert into inscritos values ('23333333M','tenis','n');
insert into inscritos values ('23333333M','futbol','n');
insert into inscritos values ('24444444A','tenis','s');
insert into inscritos values ('24444444A','futbol','s');

insert into morosos values ('22222222M');
insert into morosos values ('23333333M');
go

--4- Cree un disparador de inserción que no permita ingresar inscripciones si el socio es moroso,
-- es decir, si está en la tabla "morosos".

if OBJECT_ID('tr_checkmorosos') is not null
drop trigger tr_checkmorosos
go
create trigger tr_checkmorosos
on inscritos
for insert
as
	declare @nif char(9)
	declare CUR cursor
	for
		select nif
		from inserted
	open CUR
	fetch CUR into @nif
	while(@@FETCH_STATUS=0)
		begin
			declare @error bit
			set @error = 0
			if (@nif in (select nif from morosos))
					set @error = 1
			if @error=1
				begin
					print 'El socio con NIF:' + @nif + ' se encuentra en la tabla morosos.'
					print 'No se ha realizado la inserción.'
					rollback transaction
				end
			if @error=0
				print 'Inscripción insertada correctamente para el NIF:' + @nif
			fetch CUR into @nif
		end
	close CUR
	deallocate CUR
go

--PRUEBAS
--4a- Realice la inscripción de un socio que no deba matrículas.

set nocount on
insert into morosos values ('44444444M');
insert into socios values ('44444444M','Lucas Tinto','Artilla 880')
, ('44444444N','Abdul Traoré','Mola 180')
, ('44444444L','Jose Marino','Chaco 50');
insert into inscritos values ('44444444N','natacion','s')
, ('44444444M','tenis','s')
, ('44444444L','natacion','s');
go
set nocount off

select * from inscritos

--4b- Intente inscribir a un socio moroso.
-- El trigger se dispara, muestra un mensaje y no permite la inserción.




--5- Cree otro disparador "dis_inscritos_insertar2" para "inscritos" que ingrese el socio en la tabla "morosos" si no
-- paga la matrícula (si se ingresa 'n' para el campo "matricula"). 
-- Recuerde que podemos crear varios triggers para un mismo evento sobre una misma tabla.



--PRUEBAS
--5a- Realice la inscripción de un socio que no deba matrículas con el valor 's' para "matricula".
-- El disparador "dis_inscritos_insertar" se ejecuta y permite la transacción; el disparador
-- "dis_inscritos_insertar2" se ejecuta y permite la transacción.

--5b- Realice la inscripción de un socio que no deba matrículas con el valor 'n' para "matricula".
-- El disparador "dis_inscritos_insertar" se ejecuta y permite la transacción; el disparador
-- "dis_inscritos_insertar2" se ejecuta y permite la transacción.





--5c - Verifique que el disparador "dis_inscritos_insertar2" se ejecutó consultando la tabla
-- "morosos".

--5d - Realice la inscripción de un socio que deba matrículas con el valor 's' para "matricula".
-- El disparador "dis_inscritos_insertar" se ejecuta y no permite la transacción; el disparador
-- "dis_inscritos_insertar2" no llega a ejecutarse.

--5e - Realice la inscripción de un socio que deba matrículas con el valor 'n' para "matricula".
-- El disparador "dis_inscritos_insertar" se ejecuta y no permite la transacción; el disparador
-- "dis_inscritos_insertar2" no llega a ejecutarse.

--6 - Crea un disparador sobre la tabla "socios" para que no permita ingresar nuevos socios.
-- El mismo debe mostrar un mensaje al dispararse y deshacer la transacción.

--PRUEBAS
--6a - Intente ingresar un nuevo socio.
-- El trigger se dispara, muestra el mensaje y deshace la transacción.

--6b- Actualizar el domicilio de un socio existente.
-- El trigger no se dispara porque está definido para el evento "insert".






