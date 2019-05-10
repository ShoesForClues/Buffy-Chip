return function(thread,args)
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/parser","parser")
	
	local program=args[1]
	thread.libraries["stdlib"].root_functions.table.remove(args,1)
	
	thread.cela:execute(program,args,thread,thread.current_directory,thread.text_buffer,1)
end