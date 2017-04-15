------------------------------------------------------------------------
-- Topic:			SSIS Monitoring Deep Dive
-- Author:			Davide Mauri
-- Credits:			-
-- Copyright:		Attribution-NonCommercial-ShareAlike 2.5
-- Tab/indent size:	4
-- Last Update:		2017-04-09
-- Tested On:		SQL SERVER 2016
------------------------------------------------------------------------

use [SSISDB]
go

/*
Execute the master package
*/

select * from [catalog].[environment_references];

-- Create Execution Context
declare @execution_id bigint
exec [SSISDB].[catalog].[create_execution] @folder_name = N'SQL Saturday 613', @project_name = N'Test Project', @package_name = N'Master.dtsx', @use32bitruntime = False, 
	@reference_id = 1, -- (get from [catalog].[environment_references])
	@execution_id = @execution_id output
select @execution_id

-- Set ASYNC Execution Mode
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'SYNCHRONIZED', @parameter_value=0

-- Set NONE Logging Level
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=0 

-- Set a sample parameter value
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=30, @parameter_name=N'WaitForSec', @parameter_value=3 

-- Set another sample parameter value. Set this value to 1 if you wait the package to fail
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=30, @parameter_name=N'RaiseError', @parameter_value=1

-- Override properties values for this execution only
exec [SSISDB].[catalog].[set_execution_property_override_value] @execution_id,  @property_path=N'\Package.Variables[User::AnotherVariable]', @property_value=N'999', @sensitive=False

-- Start Execution
exec [SSISDB].[catalog].[start_execution] @execution_id
go


/*
	Analyze logged info 
*/

-- Package Executions
select * from [catalog].[executions] order by [execution_id] desc

-- Overridden execution values 
select * from [catalog].[execution_property_override_values] where [execution_id] = 36

-- Parameters execution values
select * from [catalog].[execution_parameter_values] where [execution_id] = 35

-- Executables that was used
select * from [catalog].[executables] where [execution_id] = 35 order by [package_name], [package_path]

-- Executables execution statistics
select * from [catalog].[executable_statistics] where [execution_id] = 35 order by [start_time]

-- No events logged
select [event_name], [count] = COUNT(*) from [catalog].[event_messages] where [operation_id] = 36 group by [event_name]

-- No additional context information
select c.package_path, [count] = COUNT(*) from [catalog].[event_message_context] c 
inner join [catalog].[event_messages] e on c.[event_message_id] = e.[event_message_id] 
where [operation_id] = 36
group by c.package_path

-- No details on phases
select * from [catalog].[execution_component_phases] 
where [execution_id] = 36

-- No details on dataflow
select * from [catalog].[execution_data_statistics] 
where [execution_id] = 36
