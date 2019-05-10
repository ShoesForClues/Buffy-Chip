return function(thread,args)
	local already_running=false
	for _,program in pairs(thread.cela.scheduler.threads) do
		if program.name==thread.name and program~=thread then
			already_running=true
			break
		end
	end
	if already_running==true then
		thread.text_buffer:print_line(thread.name.." is already running.")
		return
	end
	thread.text_buffer:print_line("Starting Buffy Chip...")
	
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/eztask","eztask")
	thread:import("lib/parser","parser")
	thread:import("lib/class","class")
	thread:import("lib/gel","gel")
	thread:import("lib/geffects","geffects")
	thread:import("lib/audiolib","audiolib")
	thread:import("lib/tui","tui")
	
	max_score=0
	
	local main_dir="programs/buffy_chip"
	local config=thread.scheduler.platform:require(main_dir.."/config")
	
	for _,asset in pairs(config.assets) do
		if asset[1]=="image" then
			thread.scheduler.platform:load_source(asset[2],thread.scheduler.platform.enum.file_type.image)
		elseif asset[1]=="font" then
			thread.scheduler.platform:load_source(asset[2],thread.scheduler.platform.enum.file_type.font)
		elseif asset[1]=="audio" then
			thread.scheduler.platform:load_source(asset[2],thread.scheduler.platform.enum.file_type.audio)
		end
		thread.runtime:wait()
	end
	
	thread.cela.render_mode=2
	
	thread.killed:attach(function()
		thread.cela.render_mode=1
	end)
	
	local gui_environment=thread.libraries["gel"].elements.default_element({
		parent_element=thread.cela.render_buffers[2];
		--source=thread.scheduler.platform:load_source(config.background_image,thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=1,y=1};
		};
		background_color={r=0,g=0,b=0,a=0};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
		delete_on_thread_kill=true;
	})

	thread:create_thread(thread.scheduler.platform:require(main_dir.."/main_menu"),{
		main_dir=main_dir;
		config=config;
		gui_environment=gui_environment;
	})
	
	while thread.runtime:wait() do end
end