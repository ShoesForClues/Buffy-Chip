return function(thread,args)
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/eztask","eztask")
	thread:import("lib/parser","parser")
	thread:import("lib/class","class")
	thread:import("lib/gel","gel")
	thread:import("lib/geffects","geffects")
	thread:import("lib/audiolib","audiolib")
	thread:import("lib/tui","tui")
	thread:import("lib/easing","easing")
	
	thread.cela.render_mode=1
	
	thread.text_buffer:print_line("Thanks for playing!")
	thread.text_buffer:print_line("Software developed by Jason Lee.")
	thread.text_buffer:print_line("")
	
	thread.runtime:wait(3)
	
	thread.scheduler.platform:exit()
end