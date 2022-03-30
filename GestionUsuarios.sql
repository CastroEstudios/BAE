-- Gesti�n de usuarios en el entorno MSQL Management Studio y T-SQL
-- utilizando la BD tenis
use master
go
-- 1.- XXXXXXXXX CREAR INICIOS DE SESI�N Y USUARIOS EN BD XXXXXXXXXXXXXXXXX
-- Crear un inicio de sesi�n SQL Server, con nombre user1 con pasword 'U1_1234?'
-- NO obligando al cambio de contrase�a al iniciar, 

--	BD predeterminada master

create login user1 with password= 'U1_1234?',
check_policy=off,
default_database=master,
default_language=Spanish
go

--2.- Comprueba que se ha creado el nuevo inicio de sesi�n
-- v�asen vistas de sistema (cat�logo) en BD master: sys..sql_logins y sys.server_principals

select name from sys.sql_logins
where Left(name,1)!='#'
go
-- o tambi�n consultando la vista de cat�logo master.sys.server_principals
select name from sys.server_principals 
where type='S'  -- tipo que corresponde a descripci�n SQL_LOGIN
go

--3.- Inicia sesi�n con el nuevo usuario y comprueba en explorador de objetos 
-- que BD puede ver, comprobar�s que las ve pero no puede abrir NINGUNA
-- �nicamente la BD  de sistema 'master'

-- user1 PUEDE INICIAR SESION PERO NO ESTA VINCULADO A NINGUNA BD DE LA INSTANCIA
execute as login='user1';
exec sp_who;
exec sp_helpdb
go

-- sa si puede ver todas las BD
revert;
exec sp_who;
exec sp_helpdb
go

--4.- Cambia la BD predeterminada para que sea tenis
-- y exige que en el proximo inicio de sesion el nuevo usuario cambie su contrase�a
alter login user1
with password='U1_1234?' must_change,
check_expiration=on,
check_policy=on,
default_database=tenis,
default_language=Spanish
go


--5.- Haz que use1 sea incluido como nuevo usuario en la BD tenis
-- se trata de asociar el login user1 a la BD tenis.
-- Luego le daremos permisos a user1, sobre los siguientes elementos de la BD tenis
-- a) podr� ver la tabla jugador y a la vez dar permiso a otros para eso mismo
--    user1 otorgar� permiso a un user2 para consultar la tabla Jugador
-- b) podra ver definici�n del esquema dbo
-- c) podr� consultar cualquier tabla del esquema dbo
-- d) podra actualizar solo la tabla EdicionTorneo


-- incluimos a user1 como nuevo usuario en BD tenis
use tenis
go
create user user1 for login user1
with default_schema=dbo
go

-- comprobemos que se ha creado el usuario user1 en la BD tenis
select name, create_date from sys.database_principals
where type='S'   --type S correspunde a la descripci�n de tipo SQL_USER 
go

--COMENCEMOS A DAR PERMISOS a user1

-- 5a) comenzamos d�ndole permiso a user1 para consultar tabla jugador, de forma 
-- que pueda transferir el permiso dado a otros usuarios
grant select on Jugador to user1 with grant option
go

-- ahora user1, aunque no es propietario de la tabla jugador, ni es administrador 
-- ni tenga rol de sysadmin ni el db_securityadmin, no est� incluido en esos grupos
-- y podr� dar permiso a otros usuarios para consultar la tabla Jugador

-- compru�balo en el explorador de objetos


--VAMOS A CREAR UN SEGUNDO USUARIO user2 
-- al que daremos limitados permisos en BD tenis
-- lo primero crear el inicio de sesi�n con create login
create login user2 with password= 'U2_1234?',
check_policy=off,
default_database=tenis,
default_language=Spanish
go

-- al nuevo login le haces usuario de tenis y le asignas el esquema dbo 
use tenis
go
create user user2 for login user2
with default_schema=dbo
go


-- SUPLANTAMOS a user1
-- para que las sentencias se ejecuten como si hubiera iniciado sesi�n user1

execute as login='user1';
-- compruebo que ahora quien est� acivo es user1
exec sp_who2 'active'
go

-- o tambi�n 
exec sp_who    -- observa que ahora user1 est� en estado runnable, "corriendo"

-- ahora user1 otorga permiso a user2 para consultar tabla Jugador

grant select on Jugador to user2 
go

-- el permiso de control no puede trasferirlo user1 porque no lo tiene, 
-- y aun si lo tuviese tendria que ser con "with grant option"
-- dar� ERROR si lo intenta, compru�balo
grant control on Jugador to user2 
go

-- revierto la suplantaci�n de user1, para volver a actuar como administrador sa
revert;
exec sp_who
go 

--5b) hagamos que user1, pueda ver la definici�n del esquema dbo
grant view definition on schema::dbo 
to user1 
go

-- comprueba que user1 puede ver la definici�n del esquema dbo y user2 NO
execute as login='user1'
go

-- user1 puede ver las tablas incluidas en esquema dbo de la BD tenis
-- pero solo tiene permiso de select sobre tabla Jugador, 
-- pero puede ver definici�n de todas las tablas del esquema dbo

exec sys.sp_tables @table_owner=dbo
go

-- ve las definiciones pero no vera el contenido excepto de Jugador
exec sys.sp_columns Jugador;
exec sys.sp_columns Torneo;
exec sys.sp_columns EdicionTorneo
go

-- para Edici�nTorneo no se le di� ning�n permiso
select * from EdicionTorneo
go
select * from Jugador
go

revert;
exec sp_who2
go

--SUPLANTAMOS a user2
execute as login='user2'
go

sp_who
go 

-- user2 no ve el esquema dbo, solo la tabla que tiene permiso select
exec sys.sp_Tables @table_owner=dbo
go

-- pero si puede consultar Jugador, porque user1 le otorgo el permiso
select * from Jugador


-- DESDE Explorador de objetos de SQL Management conecta (inicia sesi�n) como user2, 
-- solo ver�s la tabla Jugador del esquema dbo, no ver�s vistas ni pa del esquema dbo
-- user1 y user2 tienen por defecto el esquema dbo de BD tenis, pero no tienen los mismos 
-- permisos sobre �l. 
-- a user1 se le permite ver definici�n sobre esquema dbo: permiso vigente VIEW DEFINITION
-- user1 puede ver definici�n de todas las tablas y vistas y pa del esquema dbo



revert;
exec sp_who2 
go
--5c) permitir a user1 consultar elementos del esquema dbo
grant select on schema::dbo
to user1 

-- comprueba que ahora user1 puede ver la definici�n de las todas tablas y vistas del esquema dbo
-- ahora los permisos vigentes para user1 sobre los elementos del esquema dbo son:
-- VIEW DEFINITION y SELECT
-- mientras user2 contin�a viendo solo la tabla jugador, 
-- solo tiene SELECT on Jugador, no le hemos dado permisos sobre esquema, 
-- le hemos adjudicado el dbo por defecto pero sin otros permisos sobre el mismo 
execute as login='user1';
exec sp_who
go
exec sys.sp_Tables @table_owner=dbo
go
-- para Edici�n de torneo, al estar dentro de dbo ahora tiene permiso select
select * from EdicionTorneo
go

revert;
exec sp_who
go
--____________________ aqui me quedo _______________
-- recuerda user2 solo tiene permiso para consultar tabla Jugador, no ver� m�s
execute as login='user2';
exec sp_who;
exec sys.sp_Tables @table_owner=dbo
go

revert;
exec sp_who
go

-- 5d) permitir a user1 actualizar la tabla EdicionTorneo
grant update on EdicionTorneo to user1 
go

-- deneg�rselo con DENY o con REVOKE
deny update on EdicionTorneo to user1 
go

-- o tambi�n, y queda registrado como que nunca lo tuvo en seguridad 
-- propiedades del usuario 
revoke update on EdicionTorneo to user1 
go



--6 crea una vista dentro de un esquema MiEsquema y haz 
-- que user2 pueda consultar la vista VTorneosEspa�oles
-- la vista muestra torneos espa�oles y sus ganadores
use tenis
go

begin try
	drop schema MiEsquema
end try
begin catch
	print('no puede borra esquema sino existe o tiene alg�n objeto')
end catch
go

create schema MiEsquema
go

-- creamos como sa una vista de los torneao espa�oles y sus ganadores
create view MiEsquema.vTorneosEspagnoles
as select 
		Torneo, 
		convert(varchar,fecha,105) as fecha, 
		jugador as [ganador del torneo]
from EdicionTorneo as ET
join torneo as T
on ET.IdTorneo=T.IdTorneo
join pais as P
on T.IdPais= P.Id and p.Pais like '%Spai%'
join Jugador as J
on J.IdJugador=ET.Ganador
go

-- probemos la vista con salida ordenada seg�n torneo y �ltimas ediciones
select * from MiEsquema.vTorneosEspagnoles
order by torneo, convert(date,fecha) desc
go

-- demos permiso a user2 para consultar la vista
grant select on MiEsquema.vTorneosEspagnoles to user2
go

-- consultemos la vista como user2
execute as login='user2';
exec sp_who;
select * from MiEsquema.vTorneosEspagnoles
order by torneo, convert(date,fecha) desc
go

revert;
exec sp_who
go

-- denegamos a user2  consultar la vista
deny select on MiEsquema.vTorneosEspagnoles 
to user2

-- consultemos la vista como user2
execute as login='user2';
exec sp_who;
select * from MiEsquema.vTorneosEspagnoles
order by torneo, convert(date,fecha) desc
go


revert;
exec sp_who
go


-- 7.- Crea un user3 con pasword U3_1234? que tenga control total sobre esquema MiEsquema de BD tenis
-- con ello le damos varios permisos para ALTER, DELETE, INSERT, UPDATE, REFERENCES,EXECUTE .... 
create login user3 with password= 'U3_1234?',
check_policy=off,
default_database=tenis,
default_language=Spanish
go

use tenis
go
create user user3 for login user3
with default_schema=MIEsquema
go

-- asignamos permiso CONTROL sobre MiEsquema, que incluye EXECUTE entre otros muchos
grant control on schema::MiEsquema to user3
go
--suplantar a user3
execute as login='user3'
go
-- compruebo que user3 es usuario en la BD tenis, 
-- user3 no es sa, no ver� que otros usuarios pertenecen a la BD tenis
-- ve los usuarios 'por defecto' que existen en cualquier BD, y los 9 grupos rol de BD, db_
select * from sys.sysusers
go

exec sp_who 
go

revert;
exec sp_who;
select name from sys.sysusers
go

-- quitamos el permiso EXECUTE a user3, ahora ya no podr� ejecutar pa ni funciones
deny EXECUTE on schema::MiEsquema to user3
go

execute as login='user3';
exec sp_who
go

revert
go

-- despu�s de revertir, ahora vuelves a actuar como sa, y puedes ver: 
-- todos los usuarios asignados a tenis, no me interesa mostrar grupos de rol db_
select * from sysusers
where name not like 'db[_]%' -- descarto grupo rol de BD,   fuera patron'db_%'
go

-- usuarios con conexi�n abierta a tenis en este momento
-- usuarios conectados y las transacciones u operaciones en ejecuci�n.
exec sp_who 
go

exec sp_who 'user1';
exec sp_who 'user2';
exec sp_who 'user3'
go

exec sp_who 'sa'
go


--8  demos permiso a user3 para crear tablas en la BD

revert;
exec sp_who
go
-- creo, como sa, tabla dentro del esquema MiEsquema
create table MiEsquema.MiTabla(
id int identity primary key,
dato char)

-- comprobemos que user3 puede manejar esa tabla aunque no pueda crear tablas en el esquema
execute as login='user3'
exec sp_who 'user3'
go

create table MiEsquema.MiTabla2(
id int identity primary key,
dato char)
go
-- user3 no tiene permiso CREATE TABLE, si tiene el INSERT,SELECT, DELETE.. entre otros muchos 
-- incluidos en CONTROL
insert into MiEsquema.Mitabla(dato)
values('A'),('B')
go
select dato from MiEsquema.Mitabla
go

drop table  MiEsquema.Mitabla
go

revert
go
exec sp_who 'user3'; -- ya no est� runnable user3 
exec sp_who 'sa'
go

-- hagamos que user3 pueda crear tablas, tiene CONTROL sobre el esquema
-- pero no le hemos dado permiso para crear tablas en la BD
grant create table to user3
go

-- ahora ya tiene permiso y CONTROL sobre MiEsquema, nada le impide crear tablas
execute as login='user3';
exec sp_who 'user3'
go

create table MiEsquema.MiTablaUser3(
id int identity primary key,
dato char)
go

exec sp_tables @table_owner='MiEsquema'
go
revert
go


--9. -- LISTAR PERMISOS DE USUARIOS DE LA BD
-- consultemos las vistas de catalogo database_permissions y database_principals (master)
-- la primera contiene permisos en la BD de cada id, la segunda usuarios de la BD
select * from sys.database_permissions
go

select * from sys.database_principals 
go

-- observa que cada usuario tiene varios permisos, en la vista de permisos correlacionamos el id
-- del usuario que tiene el permiso, con el principal_id de la vista de usuario de la BD (grantee_principal_id=principal_id)
-- principal_id es el identificador de un usuario, grantee_principal_id es el identificador de un permiso

SELECT permission_name, state_desc, name, default_schema_name 
FROM sys.database_permissions -- vista de cat�logo que contiene permisos otorgados a usuarios
JOIN sys.database_principals -- vista de cat�logo que contiene usuarios DB
ON principal_id = grantee_principal_id 
ORDER BY create_date  --ordenados por antig�edad de los usuarios

-- mostrar permisos de user1 user2 y user3
SELECT permission_name, state_desc,name, default_schema_name 
FROM sys.database_permissions 
JOIN sys.database_principals 
ON principal_id = grantee_principal_id 
where name in ('user1','user2','user3')
ORDER BY create_date


--10.   ELIMINAR UN USUARIO
-- Tendr�s que quitarle todo lo que tiene tenga en la BD, antes de quitar el usuario
-- Eliminar user2, el inicio de sesi�n y su asignaci�n a tenis, dejar� de ser usuario de BD
-- y no volvera a conectar a la instancia del servidor

-- elimino lo concedido a user2
deny select on Jugador to user2 
go
-- le quito como usuario en tenis
drop user user2
go
-- elimino el inicio de sesi�n, antes cierra conexiones iniciadas
drop login user2
go
-- podria simplemente haberle desabilitado
-- compru�balo en estado desde SQLManagement 
alter login user1 disable

-- habilit�moslo de nuevo
alter login user1 enable


--11 XXXXXXXXX  ROLES de BASES DE DATOS db_ XXXXXXXXXXXXXXXXXXXXXXXXXXX
--- haz que user1 tenga los roles de BD db_datawriter y db_securityadmin
-- y con ello podr� escribir sobre las tablas de tenis y otorgar y denegar permisos

-- veamos los permisos asociados a roles de la BD db_
-- en general
EXEC sp_dbfixedrolepermission;  
go
-- en particular, v�amos los permisos asociados al rol de base de datos db_datareader
-- se le otorgar�n a los miembros de ese grupo
EXEC sp_dbfixedrolepermission @rolename='db_datareader'  
go 

EXEC sp_dbfixedrolepermission @rolename='db_datawriter'  
go 

-- mostrar todos los permisos disponibles  a nivel de base de datos
SELECT * FROM sys.fn_builtin_permissions('Database') 
ORDER BY permission_name
go

-- asignar pertenencia a rol db_ en BD tenis
exec sp_addrolemember 'db_datawriter','user1'
go
exec sp_addrolemember 'db_securityadmin','user1'
go

-- verifiquemos que permisos le hemos dado al asignale a los roles de BD
EXEC sp_dbfixedrolepermission 'db_datawriter';  
GO 
EXEC sp_dbfixedrolepermission 'db_securityadmin' 
GO

-- eliminar los permisos asociados al rol db_writer 
exec sp_droprolemember 'db_datawriter','user1'
go

exec sp_droprolemember 'db_securityadmin','user1'
go

--12 XXXXXXXXXXXX   ROLES DE SERVIDOR  XXXXXXXXXXXXXXXXXXXXXXXXX
-- Asignemos a user2 roles de servidor, queremos que sea administrador.

-- mostrar la tabla de todos permisos disponibles a nivel de servidor
SELECT * FROM sys.fn_builtin_permissions('SERVER') 
ORDER BY permission_name; 

-- roles fijos de servidor disponibles
exec sp_helpsrvrole
go
-- asignar a user1 el rol de servidor sysadmin, MUY PELIGROSO
exec sp_addsrvrolemember 'user1', 'sysadmin'
go
-- quitarle el rol
exec sp_dropsrvrolemember 'user1', 'sysadmin'
go

-- mostrar los miembros del rol de servidor sysadmin

select * from sys.server_role_members --miembros de roles
go
select * from sys.sql_logins --inicios de sesion
go

--nombre e id de roles de servidor
select name, principal_id from sys.server_principals 
where type='R' 
go

-- enlazando mediante join las tres tablas obtengo la consulta
-- que me indica los roles de servidor concedidos a los inicios de sesion
select 
	L.name as [login],  
	p.name as [rol de servidor]

from sys.server_role_members -- miembros de roles
join sys.sql_logins as L--inicios de sesion
on member_principal_id=principal_id
join sys.server_principals as P
on P.principal_id=role_principal_id 
go

 
-- mostrar los multiples permisos del rol sysadmin
exec sp_srvrolepermission 'sysadmin'
go

-- miembros que tienen asignados roles de servidor
-- inicios de sesi�n con roles de servidor asignados
exec sp_helpsrvrolemember 
go

-- mostrar miembros del rol securityadmin
exec sp_helpsrvrolemember 'securityadmin'
go