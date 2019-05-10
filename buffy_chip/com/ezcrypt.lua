return function(thread,args)
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/parser","parser")
	thread:import("lib/json","json")
	thread:import("lib/ezcrypt","ezcrypt")
	
	local _,key=thread.libraries["parser"]:get_option(args,"-k","string")
	local _,file=thread.libraries["parser"]:get_option(args,"-f","string")
	local _,output=thread.libraries["parser"]:get_option(args,"-o","string")
	local _,cycles=thread.libraries["parser"]:get_option(args,"-c","number")
	
	if key==nil then
		thread.text_buffer:print_line("Use '-k <key>'")
		return
	end
	if file==nil or thread.scheduler.platform:file_exists(file)==false then
		thread.text_buffer:print_line("Missing input file. '-f <file>'")
		return
	end
	
	local lines=thread.scheduler.platform:read_lines(file)
	local output_file=thread.scheduler.platform:create_file(output)
	output_file:open(thread.scheduler.platform.enum.file_mode.write)
	for _,line in pairs(lines) do
		local new_line=line
		for i=1,thread.libraries["stdlib"].root_functions.math.abs(cycles) do
			if cycles>0 then
				new_line=thread.libraries["ezcrypt"]:encode(key,new_line)
			elseif cycles<0 then
				new_line=thread.libraries["ezcrypt"]:decode(key,new_line)
			end
		end
		thread.text_buffer:print_line(new_line)
		output_file:write_line(new_line)
		thread.runtime:wait()
	end
	output_file:close()
	if cycles>0 then
		thread.text_buffer:print_line("Encrypted "..file.." to "..output)
	elseif cycles<0 then
		thread.text_buffer:print_line("Decrypted "..file.." to "..output)
	end
		
end