return function(thread,args)
	for _,text in pairs(args) do
		thread.text_buffer:print_line(tostring(text))
	end
end