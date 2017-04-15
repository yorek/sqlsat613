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
-- JSON_VALUE
--

select * from dbo.users_json

declare @json varchar(max)
select top (1) @json = json_data from dbo.users_json where id = 1
select @json;

select * from
( values 
	('$.firstName', json_value(@json, '$.firstName')),	
	('$.address.streetAddress', json_value(@json, '$.address.streetAddress')),	
	('$.phoneNumbers[0].number', json_value(@json, '$.phoneNumbers[0].number')),	
	('$.isAlive', json_value(@json, '$.isAlive')),	
	('$.isalive', json_value(@json, '$.isalive')),	-- CASE SENSITIVE!
	('$.children[0]', json_value(@json, '$.children[0]')),
	('$.someName', json_value(@json, '$.someName')),
	('$.phoneNumbers[10].number', json_value(@json, '$.phoneNumbers[10].number')),
	('$.spouse', json_value(@json, '$.spouse')),
	('$.address', json_value(@json, '$.address')) -- SCALAR ONLY!
) test ([path], [result])
;
go

-- In vNEXT (SQL Server v. 14.0) or on SQL Azure, path CAN be an expression and not only a literal

declare @json varchar(max);
select top (1) @json = json_data from dbo.users_json where id = 1
select [path], JSON_VALUE(@json, [path]) from
( values 
	('$.firstName'),	
	('$.address.streetAddress')
) test ([path])

