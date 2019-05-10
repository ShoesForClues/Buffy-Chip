return function(thread,args)
	if args[1]~=nil then
		if thread.scheduler.platform:file_exists(args[1])==true then
			thread.parent_thread.current_directory=args[1]
		elseif thread.scheduler.platform:file_exists(thread.parent_thread.current_directory.."/"..args[1])==true then
			thread.parent_thread.current_directory=thread.parent_thread.current_directory.."/"..args[1]
		end
	end
end