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

-- Test ISJSON function
select * from
( values 
	(null, isjson(null)),
	('', isjson(N'')),
	('{}', isjson(N'{}')),
	('[]', isjson(N'[]')),
	('[{}]', isjson(N'[{}]')),
	('{"conference": "sqlsat"}', isjson(N'{"conference": "sqlsat"}')),
	('{"conference"}', isjson(N'{"conference"}')),
	('{"conference": sqlsat}', isjson(N'{"conference": sqlsat}')),
	('{"year": "2017"}', isjson(N'{"year": "2017"}')),
	('{"year": 2017}', isjson(N'{"year": 2017}')),
	('{year: 2017}', isjson(N'{year: 2017}')),
	('{"year": ''2017''}', isjson(N'{"year": ''2017''}')),
	('{"years": [2017]}', isjson(N'{"years": [2017]}')),
	('{"years": {2017}}', isjson(N'{"years": {2017}}')),
	('{"years": {"year": 2017}}', isjson(N'{"years": {"year": 2017}}')),
	('{"false": false}', isjson(N'{"false": false}')),
	('{"true": true}', isjson(N'{"true": true}')),
	('{"null": null}', isjson(N'{"null": null}'))
) test (string, is_json)
go

-- ISJSON is perfect in Check Constraints:
drop table if exists dbo.products;
create table dbo.products
(
	id int not null constraint pk__products primary key,
	name nvarchar(100) not null,
	code bigint not null,
	[data] nvarchar(max) not null constraint ck__data check(isjson([data])=1)
)
go

insert into dbo.products values (1, 'SoundLink® Mini Bluetooth® speaker II', 123456,
N'{
  "dimensions": {
    "speaker": {
      "height": 5.1,
      "width": 18,
      "depth": 5.8,
      "weight": 0.67
    },
    "charging cradle": {
      "height": 1.59,
      "width": 15.75,
      "depth": 5.1,
      "weight": 80
    }
  }
}')
go

insert into dbo.products values (2, 'SoundLink® Mini Bluetooth® speaker II', 123456,
N'{
  "dimensions": {
    "speaker": {
      "height": 5.1,
      "width": 18,
      "depth": 5.8,
      "weight": 0.67
    },
    "charging cradle": {
      "height": 1.59,
      "width: 15.75, -- ERROR HERE
      "depth": 5.1,
      "weight": 80
    }
  }
}')
go

select * from dbo.products
go

update dbo.products set [data] = replace([data], '{', '') where id = 1
go

select * from dbo.products
go
