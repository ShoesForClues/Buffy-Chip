return function(thread,args)
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/eztask","eztask")

	local function get_thread(id)
		local target_thread
		if tonumber(id)~=nil then
			target_thread=thread.cela.scheduler.threads[tonumber(id)]
		else
			for i,t in pairs(thread.cela.scheduler.threads) do
				if t.name==id then
					target_thread=t
					break
				end
			end
		end
		if target_thread==nil then
			thread.text_buffer:print_line("Cannot find process: "..id)
		end
		return target_thread
	end

	if args[1]=="-l" then
		for i,t in pairs(thread.cela.scheduler.threads) do
			local state="running"
			if t.runtime.run_state.value==false then
				state="paused"
			end
			thread.text_buffer:print_line("PID: "..tostring(i).."\t"..tostring(t.coroutine).."\tname: "..(t.name or "unknown").."\tstate: "..state.."\tthreads: "..tostring(thread.libraries["eztask"]:get_total_thread_count(t)).."\tusage: "..tostring(thread.libraries["stdlib"]:round(thread.libraries["stdlib"]:clamp(t.runtime.usage*100,0,100),2)).."%")
		end
		thread.text_buffer:print_line("")
		thread.text_buffer:print_line("Total threads: "..tostring(thread.libraries["eztask"]:get_total_thread_count(thread.cela.scheduler)))
		thread.text_buffer:print_line("Memory usage: "..tostring(thread.libraries["stdlib"]:round(collectgarbage("count"),2)))
	elseif args[1]=="-t" then
		for i=2,#args do
			local target_thread=get_thread(args[i])
			if target_thread~=nil then
				target_thread:delete()
				target_thread.text_buffer:print_line("Terminated process: "..args[i])
			end
		end
	elseif args[1]=="-p" then
		for i=2,#args do
			local target_thread=get_thread(args[i])
			if target_thread~=nil then
				target_thread.runtime.run_state:set_value(false)
				target_thread.text_buffer:print_line("Paused process: "..args[i])
			end
		end
	elseif args[1]=="-r" then
		for i=2,#args do
			local target_thread=get_thread(args[i])
			if target_thread~=nil then
				target_thread.runtime.run_state:set_value(true)
				target_thread.text_buffer:print_line("Resumed process: "..args[i])
			end
		end
	else
		thread.text_buffer:print_line("Task options: ")
		thread.text_buffer:print_line("'-l'                  List all the current running processes.")
		thread.text_buffer:print_line("'-t <id>, <name>, ..' Terminate thread(s).")
		thread.text_buffer:print_line("'-p <id>, <name>, ..' Pause thread(s).")
		thread.text_buffer:print_line("'-r <id>, <name>, ..' Resume thread(s).")
	end
end