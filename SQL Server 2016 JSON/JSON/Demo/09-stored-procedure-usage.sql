------------------------------------------------------------------------
-- Topic:			JSON SQL Server 2016 Demo
-- Author:			Davide Mauri
-- Credits:			-
-- Copyright:		Attribution-NonCommercial-ShareAlike 2.5
-- Tab/indent size:	4
-- Last Update:		2017-04-01
-- Tested On:		SQL SERVER 14.0 CTP 1.4
------------------------------------------------------------------------
use DemoJSON
go

create sequence dbo.user_sequence
as int
start with 100
go

alter table dbo.users
add constraint df__user_id default next value for dbo.user_sequence for id
go

declare @user1 as nvarchar(max) = N'{
  "firstName": "John",
  "lastName": "Smith",
  "isAlive": true,
  "age": 40
}';

exec dbo.stp_SetUserData @user1
go

declare @user2 as nvarchar(max) = N'{
  "firstName": "Davide",
  "lastName": "Mauri",
  "isAlive": true,
  "age": 40
}';

exec dbo.stp_SetUserData @user2
go
