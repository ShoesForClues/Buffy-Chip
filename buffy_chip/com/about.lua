return function(thread,args)
	thread.text_buffer:print_line(" ______     ______     __         ______")
	thread.text_buffer:print_line("/\\  ___\\   /\\  ___\\   /\\ \\       /\\  __ \\") 
	thread.text_buffer:print_line("\\ \\ \\____  \\ \\  __\\   \\ \\ \\____  \\ \\  __ \\")
	thread.text_buffer:print_line(" \\ \\_____\\  \\ \\_____\\  \\ \\_____\\  \\ \\_\\ \\_\\")
	thread.text_buffer:print_line("  \\/_____/   \\/_____/   \\/_____/   \\/_/\\/_/")
	thread.text_buffer:print_line("Computer Environment Library Access created by Jason Lee")
	thread.text_buffer:print_line("Version: "..tostring(thread.cela._version[1]).."."..tostring(thread.cela._version[2]).."."..tostring(thread.cela._version[3]))
end