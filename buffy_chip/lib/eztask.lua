--[[************************************************************

	EZTask written by Jason Lee Copyright (c) 2019
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.
	
	This is a cooperative task scheduler, which is derived 
	from NPTask.

--************************************************************]]

local root_functions={
	string={
		len=string.len;
		sub=string.sub;
		find=string.find;
		gsub=string.gsub;
	};
	table={
		unpack=unpack;
		insert=table.insert;
		remove=table.remove;
	};
	coroutine={
		create=coroutine.create;
		resume=coroutine.resume;
		yield=coroutine.yield;
		status=coroutine.status;
	};
};

local API={
	_version={0,6,3};
	platform=nil;
}

if _VERSION=="Lua 5.3" then
	root_functions.table.unpack=table.unpack
end

function API:create_signal(multithread)
	local signal={
		binds={};
		multithread=multithread or false;
	}
	function signal:attach(action,thread)
		if action==nil or type(action)~="function" then return end
		local bind={action=action;thread=thread}
		function bind:detach()
			for i,current_bind in pairs(signal.binds) do
				if current_bind==bind then root_functions.table.remove(signal.binds,i);break end
			end
		end
		if thread~=nil then
			thread.killed:attach(function()
				bind:detach()
			end)
		end
		signal.binds[#signal.binds+1]=bind
		return bind
	end
	function signal:invoke(value)
		for _,bind in pairs(signal.binds) do
			if bind.thread~=nil and bind.thread.runtime.run_state.value==true then
				if signal.multithread==true then
					bind.thread:create_thread(function(thread)
						bind.action(value,thread)
					end)
				else
					bind.action(value)
				end
			elseif bind.thread==nil then
				bind.action(value)
			end
		end
	end
	return signal
end

function API:create_property(value,multithread)
	local property={
		value=value;
		binds={};
		multithread=multithread or false;
	}
	function property:invoke(custom_value)
		local old_value=self.value
		for _,bind in pairs(self.binds) do
			if bind.thread~=nil and bind.thread.runtime.run_state.value==true then
				if property.multithread==true then
					bind.thread:create_thread(function(thread)
						bind.action(custom_value,old_value,thread)
					end)
				else
					bind.action(custom_value,old_value)
				end
			elseif bind.thread==nil then
				bind.action(custom_value,old_value)
			end
		end
	end
	function property:set_value(value)
		if self.value==value then return end
		self:invoke(value)
		self.value=value
	end
	function property:add_value(value,index)
		if value~=nil and type(self.value)=="table" then
			self:invoke(value)
			self.value[index or #self.value+1]=value
		end
	end
	function property:remove_value(index)
		if index~=nil and type(self.value)=="table" then
			self:invoke(self.value[index])
			root_functions.table.remove(self.value,index)
		end
	end
	function property:attach(action,thread)
		if action==nil or type(action)~="function" then return end
		local bind={action=action;thread=thread}
		function bind:detach()
			for i,current_bind in pairs(property.binds) do
				if current_bind==bind then root_functions.table.remove(property.binds,i);break end
			end
		end
		if thread~=nil then
			thread.killed:attach(function()
				bind:detach()
			end)
		end
		property.binds[#property.binds+1]=bind
		return bind
	end
	return property
end

function API:get_total_thread_count(current_thread)
	local thread_count=#current_thread.threads
	for _,t in pairs(current_thread.threads) do
		thread_count=thread_count+API:get_total_thread_count(t)
	end
	return thread_count
end

function API:create_scheduler(properties)
	properties=properties or {}
	local scheduler={
		runtime={
			current_tick=0;
			run_state=API:create_property(true);
		};
		cycle_speed=properties.cycle_speed or 60;
		threads={};
		thread_initialization=properties.thread_initialization;
	}
	
	function scheduler:create_thread(environment,args,parent_thread)
		if type(environment)=="string" then
			environment=API.platform:require(environment)
		end
		if type(environment)~="function" then return end
		local thread={
			runtime={
				run_state=API:create_property(true);
				resume_state=true;
				current_tick=0;
				resume_tick=0;
				usage=0;
			};
			killed=API:create_signal();
			parent_thread=parent_thread or scheduler;
			scheduler=scheduler;
			threads={};
			binds={};
			libraries={};
			index=0;
		}
		
		function thread.runtime:wait(duration,yield_sub_threads)
			if yield_sub_threads==true then
				thread.runtime.resume_tick=thread.parent_thread.runtime.current_tick+(duration or 0)
				local pause_tick=thread.parent_thread.runtime.current_tick
				root_functions.coroutine.yield()
				return thread.parent_thread.runtime.current_tick-pause_tick
			else
				local start_tick=thread.parent_thread.runtime.current_tick
				repeat thread.runtime:wait(0,true) until thread.parent_thread.runtime.current_tick>start_tick+(duration or 0)
				return thread.parent_thread.runtime.current_tick-start_tick
			end
		end
		
		function thread:resume(tick,absolute_timing)
			local output_buffer
			if root_functions.coroutine.status(thread.coroutine)=="dead" then
				thread:delete()
			elseif thread.runtime.run_state.value==true and root_functions.coroutine.status(thread.coroutine)=="suspended" and thread.runtime.resume_tick<=thread.parent_thread.runtime.current_tick then
				local start_tick=API.platform:get_tick()
				if absolute_timing==true then
					thread.runtime.current_tick=tick
				else
					thread.runtime.current_tick=thread.runtime.current_tick+1/scheduler.cycle_speed
				end
				local _,output=root_functions.coroutine.resume(thread.coroutine,thread,args)
				if output~=nil then
					output_buffer=(output_buffer or "")..output.."\n"
				end
				for i,sub_thread in pairs(thread.threads) do
					sub_thread.index=i
					output=sub_thread:resume(tick,absolute_timing)
					if output~=nil then
						output_buffer=(output_buffer or "")..output.."\n"
					end
				end
				thread.runtime.usage=(API.platform:get_tick()-start_tick)/(1/scheduler.cycle_speed)
			end
			return output_buffer
		end
		
		function thread:import(library,library_name)
			if library==nil or thread==nil then return end
			library_name=library_name or root_functions.string.sub(library_name,(library_name:match("^.*()/") or 0)+1,root_functions.string.len(library_name))
			if type(library)=="function" then
				thread.libraries[library_name]=library(thread)
			elseif type(library)=="string" then
				library=API.platform:require(library)
				if type(library)=="function" then
					thread.libraries[library_name]=library(thread)
				else
					thread.libraries[library_name]=library
				end
			else
				thread.libraries[library_name]=library
			end
			if type(thread.libraries[library_name])=="table" then
				if thread.libraries[library_name]._dependencies~=nil and type(thread.libraries[library_name]._dependencies)=="table" then
					for _,dep in pairs(thread.libraries[library_name]._dependencies) do
						if thread.libraries[dep]==nil then
							API.platform:warn("'"..library_name.."' requires dependency: '"..dep.."'")
						end
					end
				end
				if thread.libraries[library_name].post_import_setup~=nil then
					thread.libraries[library_name]:post_import_setup()
				end
			end
			return thread.libraries[library_name]
		end
		
		function thread:link_bind(bind)
			if bind~=nil and type(bind)=="table" and bind.detach~=nil then
				thread.binds[#thread.binds+1]=bind
			end
			return bind
		end
		
		function thread:delete(...)
			thread.runtime.run_state:set_value(false)
			thread.killed:invoke(root_functions.table.unpack({...}))
			for _,bind in pairs(thread.binds) do --Disconnect all signals
				bind:detach()
			end
			for _,sub_thread in pairs(thread.threads) do
				sub_thread:delete()
			end
			if thread.parent_thread.threads[thread.index]==thread then
				root_functions.table.remove(thread.parent_thread.threads,thread.index)
			else
				for i,obj in pairs(thread.parent_thread.threads) do
					if obj==thread then
						--thread.parent_thread.threads[i]=nil
						root_functions.table.remove(thread.parent_thread.threads,i)
						break
					end
				end
			end
		end
		
		function thread:create_thread(environment,args,parent_thread)
			return thread.parent_thread:create_thread(environment,args,parent_thread or thread)
		end
		
		if scheduler.thread_initialization~=nil then
			scheduler.thread_initialization(thread)
		end
		
		thread.runtime.run_state:attach(function(state)
			if state==true then
				for _,sub_thread in pairs(thread.threads) do
					sub_thread.runtime.run_state:set_value(sub_thread.runtime.resume_state)
				end
			elseif state==false then
				for _,sub_thread in pairs(thread.threads) do
					sub_thread.runtime.resume_state=sub_thread.runtime.run_state.value
					sub_thread.runtime.run_state:set_value(false)
				end
				thread.runtime.usage=0
			end
		end)
		
		thread.coroutine=root_functions.coroutine.create(environment)
		thread.parent_thread.threads[#thread.parent_thread.threads+1]=thread
		return thread,#thread.parent_thread.threads
	end
		
	scheduler.runtime.run_state:attach(function(state) --simulate the pause event for scheduler
		if state==true then
			for _,sub_thread in pairs(scheduler.threads) do
				sub_thread.runtime.run_state:set_value(sub_thread.runtime.resume_state)
			end
		elseif state==false then
			for _,sub_thread in pairs(scheduler.threads) do
				sub_thread.runtime.resume_state=sub_thread.runtime.run_state.value
				sub_thread.runtime.run_state:set_value(false)
			end
		end
	end)
	
	function scheduler:cycle(tick,absolute_timing)
		local output_buffer
		scheduler.cycle_speed=1/(tick-scheduler.runtime.current_tick)
		scheduler.runtime.current_tick=tick
		for i,thread in pairs(scheduler.threads) do
			thread.index=i
			local output=thread:resume(tick,absolute_timing)
			if output~=nil then
				output_buffer=(output_buffer or "")..output
			end
		end
		return output_buffer
	end
	
	if properties.scheduler_initialization~=nil and type(properties.scheduler_initialization)=="function" then
		properties.scheduler_initialization(scheduler)
	end
	
	return scheduler
end

return API