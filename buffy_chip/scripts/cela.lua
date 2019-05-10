return function(thread,args)
	args=args or {}
	
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/eztask","eztask")
	thread:import("lib/parser","parser")
	thread:import("lib/class","class")
	thread:import("lib/gel","gel")
	thread:import("lib/geffects","geffects")
	thread:import("lib/audiolib","audiolib")
	thread:import("lib/tui","tui")
	thread:import("lib/cpml","cpml")
	
	local cela={
		_version={3,1,3};
		platform=thread.scheduler.platform;
		settings=thread.scheduler.platform:require("settings");
		render_buffers={
			[1]=thread.libraries["tui"].elements.text_buffer_element({ --Text mode
				--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
				size={
					offset={x=0,y=0};
					scale={x=1,y=1};
				};
				background_color={r=0,g=0,b=0,a=0};
				source_color={r=0,g=0,b=0,a=0};
				wrapped=false;
				visible=true;
				char_size={x=12,y=12};
				char_color={background={r=0,g=0,b=0,a=0},foreground={r=1,g=1,b=1,a=0}};
				font_size=12;
				text_scaled=false;
				font=thread.scheduler.platform:load_source("assets/fonts/terminus.ttf",thread.scheduler.platform.enum.file_type.font);
				buffer=thread.scheduler.platform:create_buffer();
			});
			[2]=thread.libraries["gel"].elements.default_element({ --Graphics mode
				--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
				size={
					offset={x=0,y=0};
					scale={x=1,y=1};
				};
				background_color={r=0,g=0,b=0,a=0};
				source_color={r=0,g=0,b=0,a=0};
				wrapped=false;
				visible=true;
				buffer=thread.scheduler.platform:create_buffer();
			});
		};
		render_mode=1;
	}
	
	function thread.scheduler.platform:print(...) cela.render_buffers[1]:print_line(...) end
	
	thread.libraries["eztask"].platform=thread.scheduler.platform
	
	cela.scheduler=thread.libraries["eztask"]:create_scheduler({
		thread_initialization=function(current_thread)
			current_thread.name="no name"
			current_thread.cela=cela
			current_thread.text_buffer=cela.render_buffers[1]
			current_thread.current_directory=cela.settings.path[1]
			current_thread.file_directory=""
		end;
		scheduler_initialization=function(scheduler)
			scheduler.platform=thread.scheduler.platform
		end;
	})
	
	function cela:execute(command,args,current_thread,current_directory,current_text_buffer,run_type)
		if command==nil then return end
		args=args or {}
		
		current_directory=current_directory or cela.settings.path[1]
		current_text_buffer=current_text_buffer or cela.render_buffers[1]
		
		local program_name,program,program_thread=command,nil,current_thread
		
		for _,path in pairs(thread.libraries["stdlib"]:group_tables({current_directory},cela.settings.path)) do
			if thread.scheduler.platform:file_exists(path.."/"..program_name..".lua")==true then
				program=thread.scheduler.platform:require(path.."/"..program_name)
				break
			end
		end
		
		if program~=nil then
			if type(program)=="function" then
				if run_type==1 then
					program_thread=cela.scheduler:create_thread(program,args)
					program_thread.name=thread.libraries["parser"]:get_name(program_name)
					program_thread.text_buffer=current_text_buffer
					program_thread.current_directory=current_directory
					program_thread.file_directory=current_directory.."/"..program_name
				else
					program_thread=current_thread:create_thread(program,args)
					program_thread.name=thread.libraries["parser"]:get_name(program_name)
					program_thread.cela=cela
					program_thread.text_buffer=current_text_buffer
					program_thread.current_directory=current_directory
					program_thread.file_directory=current_directory.."/"..program_name
					
					local program_completed=false
					program_thread.killed:attach(function()
						program_completed=true
					end)
					
					repeat current_thread.runtime:wait() until program_completed==true
				end
			elseif type(program)=="string" then
				for line,sub_command in pairs(thread.libraries["parser"]:get_lines(program)) do
					local parameters=thread.libraries["parser"]:parse(sub_command)
					local program_name=parameters[1]
					thread.libraries["stdlib"].root_functions.table.remove(parameters,1)
					cela:execute(program_name,parameters,current_thread,current_directory,current_text_buffer,run_type)
				end
			end
		else
			current_text_buffer:print_line("'"..program_name.."' is invalid.")
		end
		cela.render_mode=1;
	end
	
	function cela:panic(error_message)
		cela.render_mode=1
		cela.render_buffers[1]:clear()
		cela.render_buffers[1]:print_line("FATAL ERROR: "..error_message or "Unknown error.")
		cela.render_buffers[1]:print_line("")
		cela.render_buffers[1]:print_line("MEMORY USAGE: "..tostring(collectgarbage("count")))
		cela.render_buffers[1]:print_line("")
		for i,t in pairs(cela.scheduler.threads) do
			cela.render_buffers[1]:print_line("TERMINATING PID: "..tostring(i).."\t"..tostring(t.coroutine).."\tname: "..t.name or "N/A")
			t:delete()
		end
		cela.render_buffers[1]:print_line("")
	end
	
	thread:link_bind(thread.scheduler.platform.screen_resolution:attach(function(resolution)
		if args.auto_resize==true and cela.render_buffers[cela.render_mode]~=nil then
			cela.render_buffers[cela.render_mode].buffer.value:release()
			cela.render_buffers[cela.render_mode].buffer:set_value(thread.scheduler.platform:create_buffer(resolution.x,resolution.y))
		end
	end))
	
	thread:link_bind(thread.scheduler.platform.render_stepped:attach(function()
		thread.scheduler.platform:render_image(
			(cela.render_buffers[cela.render_mode] or cela.render_buffers[1]).buffer.value,
			{x=0,y=0},
			thread.scheduler.platform.screen_resolution.value,
			0,
			nil,
			{r=1,g=1,b=1,a=0},
			{r=1,g=1,b=1,a=0},
			thread.scheduler.platform.enum.filter_mode.nearest,
			0
		)
	end))
	
	thread:create_thread(function(t)
		while t.runtime:wait() do
			if cela.render_buffers[cela.render_mode]~=nil then
				thread.scheduler.platform:set_current_buffer(cela.render_buffers[cela.render_mode].buffer.value)
				cela.render_buffers[cela.render_mode]:render()
				thread.scheduler.platform:set_current_buffer()
			end
		end
	end)
	
	cela.scheduler:create_thread(function(core_thread)
		cela:execute("autoexec",{},core_thread,core_thread.current_directory,core_thread.text_buffer,1)
	end)
	
	while thread.runtime:wait() do
		cela.render_buffers[1]:print(cela.scheduler:cycle(thread.scheduler.platform:get_tick()))
	end
end