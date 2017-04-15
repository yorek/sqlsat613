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

declare @json varchar(max)
set @json = 
N'{
  "firstName": "John",
  "lastName": "Smith",
  "children": []
}';

select * from
( values  
	('Update existing value', json_modify(@json, '$.firstName', 'Davide')),
	('Insert scalar value', json_modify(@json, '$.isAlive', 'true')),
	('Insert array (wrong)', json_modify(@json, '$.preferredColors', '["Blue", "Black"]')), -- Wrong way, due to automatic escaping
	('Insert array (right)', json_modify(@json, '$.preferredColors', json_query('["Blue", "Black"]'))), 
	('Append to array', json_modify(@json, 'append $.children', 'Annette')), 
	('Replace an array with a scalar', json_modify(@json, '$.children', 'Annette')),
	('Add an object', json_modify(@json, '$.phoneNumbers', json_query('{"type": "home","number": "212 555-1234"}'))),
	('Remove an object', json_modify(@json, '$.firstName', null))
) t([action], result)
go

-- View existing data
select * from dbo.users_json
go

-- Add a new sample user
insert into dbo.users_json
select 3, json_data = json_modify(json_data, '$.firstName', 'Andy') from dbo.users_json where id = 1
go

-- View new user data
select * from dbo.users_json where id = 3
go

-- Update last name and add a new phone number
update 
	dbo.users_json
set
	json_data = 
		json_modify(
			json_modify(json_data, '$.lastName', 'Green'),
			'append $.phoneNumbers',
			json_query('{"type": "fax","number": "212 555-1234"}')
			)
where 
	json_value(json_data, '$.firstName') = 'Andy'
go

-- View result
select * from dbo.users_json where id = 3
go