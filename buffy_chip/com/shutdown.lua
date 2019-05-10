return function(thread,args)
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/parser","parser")
	
	local reboot,_=thread.libraries["parser"]:get_option(args,"-r","boolean")
	local maintenance,_=thread.libraries["parser"]:get_option(args,"-m","boolean")
	
	local function shutdown(reboot)
		local platform=thread.scheduler.platform:get_running_platform()
		if thread.libraries["stdlib"].root_functions.string.find(thread.libraries["stdlib"].root_functions.string.lower(platform.operating_system),"win") then
			if reboot==true then
				thread.scheduler.platform:execute_command("shutdown /r /t 0")
			else
				thread.scheduler.platform:execute_command("shutdown /s /t 0")
			end
		elseif thread.libraries["stdlib"].root_functions.string.find(thread.libraries["stdlib"].root_functions.string.lower(platform.operating_system),"nix") then
			if reboot==true then
				thread.scheduler.platform:execute_command("reboot now")
			else
				thread.scheduler.platform:execute_command("shutdown now")
			end
		end
	end
	
	if maintenance~=true then
		shutdown(reboot)
	end
	thread.scheduler.platform:exit()
	thread.runtime:wait(0.1)
	thread.text_buffer:print_line("Failed to terminate system.")
end