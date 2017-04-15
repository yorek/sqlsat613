------------------------------------------------------------------------
-- Topic:			JSON SQL Server / Azure SQL Demo
-- Author:			Davide Mauri
-- Credits:			-
-- Copyright:		Attribution-NonCommercial-ShareAlike 2.5
-- Tab/indent size:	4
-- Last Update:		2017-04-01
-- Tested On:		SQL SERVER 14.0 CTP 1.4
------------------------------------------------------------------------
use DemoJSON
go

--
-- JSON_VALUE with STRICT path mode
--
declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select @json;

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.firstName')	
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.address.streetAddress')	
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.phoneNumbers[0].number')
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.isAlive')	
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.isalive')	-- CASE SENSITIVE!
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.children[0]')
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.someName')
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.phoneNumbers[10].number')
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.spouse')	
go

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select json_value(@json, 'strict $.address') -- SCALAR ONLY
go

