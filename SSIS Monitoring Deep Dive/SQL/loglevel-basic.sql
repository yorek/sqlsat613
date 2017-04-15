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

-- Get Environment Id
select * from [catalog].[environment_references];

-- Create Execution Context
declare @execution_id bigint
exec [SSISDB].[catalog].[create_execution] @folder_name = N'SQL Saturday 613', @project_name = N'Test Project', @package_name = N'Master.dtsx', @use32bitruntime = False, 
	@reference_id = 1, -- (get from [catalog].[environment_references])
	@execution_id = @execution_id output
select @execution_id

-- Set ASYNC Execution Mode
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'SYNCHRONIZED', @parameter_value=0

-- Set BASIC Logging Level
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=1

-- Set a sample parameter value
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=30, @parameter_name=N'WaitForSec', @parameter_value=3 

-- Set another ample parameter value. Set this value to 1 if you wait the package to fail
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
select * from [catalog].[execution_property_override_values] where [execution_id] = 37

-- Parameters execution values
select * from [catalog].[execution_parameter_values] where [execution_id] = 37

-- Executables that was used
select * from [catalog].[executables] where [execution_id] = 37 order by [package_name], [package_path]

-- Executables execution statistics
select * from [catalog].[executable_statistics] where [execution_id] = 38 order by [start_time]

-- For which package we got events?
select [package_name], [count] = COUNT(*) from [catalog].[event_messages] where [operation_id] = 38 group by [package_name]

-- Which event was logged? 
select [event_name], [count] = COUNT(*) from [catalog].[event_messages] where [operation_id] = 38 group by [event_name]

-- Take a look at the logged events
select * from [catalog].[event_messages] where [operation_id] = 37 order by [event_message_id]

-- Focus on a specific package
select * from [catalog].[event_messages] where [operation_id] = 37
and [package_name] = 'Master.dtsx'
order by [event_message_id]

-- Focus on a specific package and a specific component
select * from [catalog].[event_messages] where [operation_id] = 37
and [package_name] = 'Child.dtsx' and [message_source_name] = 'Do Stuff'
order by [event_message_id]

-- For some events (OnPreExecute, OnError) additional information are logged
select e.event_name, [count] = COUNT(*) from [catalog].[event_message_context] c 
inner join [catalog].[event_messages] e on c.[event_message_id] = e.[event_message_id] 
where [operation_id] = 38
group by e.event_name

-- No details on phases
select * from [catalog].[execution_component_phases] 
where [execution_id] = 38

-- No details on dataflow
select * from [catalog].[execution_data_statistics] 
where [execution_id] = 38
