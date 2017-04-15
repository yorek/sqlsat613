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

-- Set RUNTIME LINEAGE Logging Level
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=4

-- Set a sample parameter value
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id, @object_type=30, @parameter_name=N'WaitForSec', @parameter_value=3 

-- Set another ample parameter value. Set this value to 1 if you wait the package to fail
exec [SSISDB].[catalog].[set_execution_parameter_value] @execution_id,  @object_type=30, @parameter_name=N'RaiseError', @parameter_value=0

-- Override properties values for this execution only
exec [SSISDB].[catalog].[set_execution_property_override_value] @execution_id,  @property_path=N'\Package.Variables[User::AnotherVariable]', @property_value=N'999', @sensitive=False

-- Start Execution
exec [SSISDB].[catalog].[start_execution] @execution_id
go


/*
Analyze logged info 
*/
select * from [catalog].[executions] order by [execution_id] desc

select * from [catalog].[execution_property_override_values] where [execution_id] = 33

select * from [catalog].[execution_parameter_values] where [execution_id] = 33

select * from [catalog].[executables] where [execution_id] = 33 order by [package_name], [package_path]

select * from [catalog].[executable_statistics] where [execution_id] = 33 order by [start_time]

-- Now log info in event messages table are available, but only for OnWarning and OnError and OnPreExecute events
select distinct [package_name] from [catalog].[event_messages] where [operation_id] = 33 

select distinct [event_name] from [catalog].[event_messages] where [operation_id] = 33

select * from [catalog].[event_messages] where [operation_id] = 33 order by [event_message_id]

select * from [catalog].[event_messages] where [operation_id] = 33 
AND subcomponent_name = 'SSIS.Pipeline'
ORDER by [event_message_id]

SELECT * from [catalog].[event_messages] where [operation_id] = 33
and [package_name] = 'Master.dtsx'
order by [event_message_id]

select * from [catalog].[event_messages] where [operation_id] = 33
and [package_name] = 'Child.dtsx' and [message_source_name] = 'Do Stuff'
order by [event_message_id]

-- When an OnError event occours you have information on all properties releated to the event here
select * from [catalog].[event_message_context] c 
	inner join [catalog].[event_messages] e on c.[event_message_id] = e.[event_message_id] 
	where [operation_id] = 32

-- Phases contains some more detailed information on otherwise non-logged event (PreExecute, ProcessInput...) related to the DataFlow
select * from [catalog].[execution_component_phases] where [execution_id] = 33
select distinct phase from  [catalog].[execution_component_phases] where [execution_id] = 33

-- Performance of each component's execution
select package_name, task_name, subcomponent_name, execution_path,
    SUM(DATEDIFF(ms,start_time,end_time)) as active_time,
    DATEDIFF(ms,min(start_time), max(end_time)) as total_time,
	count(*)
	from [catalog].execution_component_phases
where 
	execution_id = 31
group by 
	package_name, task_name, subcomponent_name, execution_path
order by 
	package_name, task_name, subcomponent_name, execution_path

-- Focus on a specific DataFlow transformation
select * from [catalog].[execution_component_phases] 
where [execution_id] = 31
and [execution_path] = '\Master\Execute Child Package\Child\Load Results[1]\Load Child Results Table' and [subcomponent_name] = 'Lookup B'

SELECT * FROM [catalog].dm_execution_performance_counters(33)

SELECT * FROM catalog.event_messages WHERE operation_id = 33




