return function(thread,args)
	for _,command in pairs(args) do
		local str=thread.scheduler.platform:execute_command(command)
		local x,a,b=1
		while x<string.len(str) do
			a,b=string.find(str,'.-\n',x)
			if not a then
				break
			else
				thread.text_buffer:print_line(string.sub(str,a,b))
			end
			x=b+1
		end;
	end
end