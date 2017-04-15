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

-- Set CUSTOM Logging Level
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=100
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=50, @parameter_name=N'CUSTOMIZED_LOGGING_LEVEL', @parameter_value=N'CustomLevelDemo'

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
SELECT * from [catalog].[executions] order by [execution_id] desc

-- Overridden execution values 
select * from [catalog].[execution_property_override_values] where [execution_id] = 39

-- Parameters execution values
select * from [catalog].[execution_parameter_values] where [execution_id] = 39

-- Executables that was used
select * from [catalog].[executables] where [execution_id] = 39 order by [package_name], [package_path]

-- Executables execution statistics
select * from [catalog].[executable_statistics] where [execution_id] = 39 order by [start_time]

-- For which package we got events?
select [package_name], [count] = COUNT(*) from [catalog].[event_messages] where [operation_id] = 39 group by [package_name]

-- Which event was logged? 
select [event_name], [count] = COUNT(*) from [catalog].[event_messages] where [operation_id] = 39 group by [event_name]

-- Take a look at the logged events
select * from [catalog].[event_messages] where [operation_id] = 34 order by [event_message_id]

-- Focus on a specific event
select * from [catalog].[event_messages] where [operation_id] = 34
and [package_name] = 'Master.dtsx'
and [event_name] = 'PipelineComponentTime'
order by [event_message_id]

-- For some events additional information are logged
select c.package_path, [count] = COUNT(*) from [catalog].[event_message_context] c 
inner join [catalog].[event_messages] e on c.[event_message_id] = e.[event_message_id] 
where [operation_id] = 34
group by c.package_path

-- Focus on a specific executable
select * from [catalog].[event_message_context] c 
inner join [catalog].[event_messages] e on c.[event_message_id] = e.[event_message_id] 
where [operation_id] = 34
and [c].package_path = '\Package\Load Results'

-- Focus on a specific event
select * from [catalog].[event_message_context] c 
inner join [catalog].[event_messages] e on c.[event_message_id] = e.[event_message_id] 
where [operation_id] = 34
and [e].[event_name] = 'OnError'

-- Phases are also available
select phase, count(*) as [count] from  [catalog].[execution_component_phases] where [execution_id] = 34 group by phase
select * from [catalog].[execution_component_phases] where [execution_id] = 34

-- Calculate active and total run time
select 
	package_name, task_name, subcomponent_name, execution_path,
    SUM(DATEDIFF(ms,start_time,end_time)) as active_time,
    DATEDIFF(ms,min(start_time), max(end_time)) as total_time,
	count(*)
from 
	[catalog].execution_component_phases
where 
	execution_id = 34
group by 
	package_name, task_name, subcomponent_name, execution_path
order by 
	package_name, task_name, subcomponent_name, execution_path

-- Focus on a specific transformation
select * from [catalog].[execution_component_phases] 
where [execution_id] = 34
and [execution_path] = '\Master\Execute Child Package\Child\Load Results[1]\Load Child Results Table' and [subcomponent_name] = 'Lookup B'

-- Now we also get details on DataFlows
select * from [catalog].[execution_data_statistics] 
where [execution_id] = 34

-- Calculate total rows
select 
	[package_name], [task_name], [execution_path], [source_component_name], [destination_component_name], [dataflow_path_name],
	total_rows_sent = sum([rows_sent]) 
from 
	[catalog].[execution_data_statistics] 
where 
	[execution_id] = 34
group by 
	[package_name], [task_name], [execution_path], [source_component_name], [destination_component_name], [dataflow_path_name]
