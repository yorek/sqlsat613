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

drop procedure if exists dbo.stp_SetUserData
go

create procedure dbo.stp_SetUserData
@payload nvarchar(max)
as
if (isjson(@payload) != 1)
	throw 50001, '@payload is not a valid json', 16;

with cte as
(
	select * from openjson(@payload) with 
	(
		firstName nvarchar(100),
		lastName nvarchar(100),
		isAlive bit,
		age int
	)
)
merge into
	dbo.users as t
using
	cte as s 
on
	t.firstName = s.firstName and t.lastName = s.lastName
when matched then
	update set 
		t.isAlive = s.isAlive,
		t.age = s.age
when not matched then
	insert 
		(firstName, lastName, isAlive, age) 
	values 
		(s.firstName, s.lastName, s.isAlive, s.age)
output
	$action, inserted.id
;