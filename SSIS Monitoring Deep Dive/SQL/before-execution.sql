------------------------------------------------------------------------
-- Topic:			SSIS Monitoring Deep Dive
-- Author:			Davide Mauri
-- Credits:			-
-- Copyright:		Attribution-NonCommercial-ShareAlike 2.5
-- Tab/indent size:	4
-- Last Update:		2017-04-09
-- Tested On:		SQL SERVER 2016
------------------------------------------------------------------------

USE [SSISDB]
go


-- Memo: Deploy the project, than:

-- Folders
select * from [catalog].[folders]
go

-- Project
select * from [catalog].[projects] 
where [folder_id] = 1
go

-- Built-In Versioning
select * from [catalog].[object_versions]
where [object_id] = 1
go

-- View table just after deployment
select * from [catalog].[object_parameters] 
where [project_id] = 1
go

-- Configure the "Sample Parameter" value in Master.dtsx
exec [SSISDB].[catalog].[set_object_parameter_value] 
	@folder_name = N'SQL Saturday 613', 
	@project_name = N'Test Project', 
	@object_name = N'Master.dtsx', 
	@object_type = 30, 
	@parameter_name = N'SampleParameter', 
	@value_type = 'V', 
	@parameter_value = N'SQLSAT #613'
go

-- and then view table content again
select * from [catalog].[object_parameters] 
where [project_id] = 1 
and [value_set] = 1
go

-- Create Environment "Sample 1"
exec [SSISDB].[catalog].[create_environment] 
	@folder_name = N'SQL Saturday 613',
	@environment_name = N'Sample 1', 
	@environment_description = N'Just a sample Environment'
go

-- View environments in the "Test Folder" folder
select * from [catalog].[environments]
where [folder_id] = 1
go

-- Create Environment Variables in environment "Sample 1"
exec [SSISDB].[catalog].[create_environment_variable] 
	@folder_name = N'SQL Saturday 613',
    @environment_name = N'Sample 1', 
	@variable_name = N'My Message',
    @description = N'Just a message', 
	@value = N'Hi there, this is Sample 1',
    @data_type = N'String', 
	@sensitive = 0;

exec [SSISDB].[catalog].[create_environment_variable] 
	@folder_name = N'SQL Saturday 613',
    @environment_name = N'Sample 1', 
	@variable_name = N'A number',
    @description = N'My lucky number', 
	@value = 5,
    @data_type = N'Int32', 
	@sensitive = 0;
go

-- View the variables created in the "Sample 1" environment 
select * from [catalog].[environment_variables]
go

-- Reference "Sample 1" Environment
declare @reference_id bigint
exec [SSISDB].[catalog].[create_environment_reference] 
	@folder_name = N'SQL Saturday 613', 
	@project_name = N'Test Project', 
	@environment_name = N'Sample 1', 
	@reference_type = 'R',
	@reference_id = @reference_id output
go

-- View the environment referenced (and thus usable) by the "Test Project" project
select * from [catalog].[environment_references]
where [project_id] = 1
go

-- Now set the Project Parameters values using a Reference to Environment Variables
-- instead of settint the values directly
exec [SSISDB].[catalog].[set_object_parameter_value] 
	@folder_name = N'SQL Saturday 613', 
	@project_name = N'Test Project', 
	@parameter_name = N'SampleParameter', 
	@object_name = N'Master.dtsx', 
	@object_type = 30, 
	@value_type = 'R', 
	@parameter_value = N'My Message'
;

exec [SSISDB].[catalog].[set_object_parameter_value] 
	@folder_name = N'SQL Saturday 613', 
	@project_name = N'Test Project', 
	@parameter_name = N'WaitForSec', 
	@object_name = N'Master.dtsx', 
	@object_type = 30, 
	@value_type = 'R', 
	@parameter_value = N'A Number'
;
go

-- Now let's check the object_parameters table again
select * from [catalog].[object_parameters] 
where [project_id] = 1
and  [value_set] = 1

