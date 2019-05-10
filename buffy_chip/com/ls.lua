return function(thread,args)
	local current_directory=args[1] or thread.current_directory
	thread.text_buffer:print_line("Directory of '"..current_directory.."'")
	for i,file in pairs(thread.scheduler.platform:get_sub_files(current_directory)) do
		thread.text_buffer:print_line(file)
	end
end