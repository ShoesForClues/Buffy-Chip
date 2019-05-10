--________________________________Dependencies_________________________________
local stdplib=require("system/lib/stdplib")
--local fs=require("fs")
--local timer=require("timer")
--_____________________________________________________________________________

local platform={
	_target="luvit";
	_version={0,0,1};
	
	start_tick=os.clock();
	
	enum={
		filter_mode={
			linear="linear";
			nearest="nearest";
		};
		blend_mode={
			alpha="alpha";
			multiply="multiply";
			replace="replace";
			screen="screen";
			add="add";
			subtract="subtract";
			lighten="lighten";
			darken="darken";
		};
		blend_alpha_mode={
			alpha_multiply="alphamultiply";
			pre_multiplied="premultiplied";
		};
		audio_state={
			play=0x01;
			stop=0x02;
			pause=0x03;
			resume=0x04;
		};
		file_type={
			image=0x05;
			font=0x06;
			audio=0x07;
			script=0x08;
			model=0x09;
		};
		format={
			color={
				r8="r8";
				rg8="rg8";
				rgba8="rgba8";
				srgba8="srgba8";
				rgba16="rba16";
				r16f="r16f";
				rg16f="rg16f";
				rgba16f="rgba16f";
				r32f="r32f";
				rg32f="rg32f";
				rgba32f="rgba32f";
				rgba4="rgba4";
				rgb5a1="rgb5a1";
				rgb565="rgb565";
				rgb10a2="rgb10a2";
				rg11b10f="rg11b10f";
			};
			depth={
				stencil8="stencil8";
				depth16="depth16";
				depth24="depth24";
				depth32f="depth32f";
				depth24_stencil98="depth24stencil8";
				depth32f_stencil8="depth32f_stencil8";
			};
		};
		screen_mode={
			full_screen="FULL_SCREEN";
			window="WINDOW";
		};
		value_type={
			int={};
			float={};
			matrix_4={};
			vector_4={};
		};
		file_mode={
			read="r";
			write="w";
		};
	};
	
	assets={}; --Asset bank
	
	text_input=stdplib:create_signal();
	key_state=stdplib:create_signal();
	joystick_key_state=stdplib:create_signal();
	mouse_key_state=stdplib:create_signal();
	mouse_moved=stdplib:create_signal();
	mouse_scrolled=stdplib:create_signal();
	mouse_position=stdplib:create_property({x=0,y=0});
	pointers=stdplib:create_property({});

	update_stepped=stdplib:create_signal();
	render_stepped=stdplib:create_signal();
	
	current_screen_mode=stdplib:create_property("WINDOW");
	screen_resolution=stdplib:create_property({x=0,y=0});
	
	output_update=stdplib:create_signal();
	
	default={
		font={};
		current_file="";
	};
}

function platform:get_running_platform()                                                           --Get the platform specs
	return {operating_system=los.type();bits=32;}
end

function platform:execute_command(code,multithread)                                                --Execute OS specific commands
	if code==nil then return end
	local output=""
	
	if multithread==true then
		
	else
		local handle=io.popen(code)
		output=handle:read("*a")
		handle:close()
	end
	
	return output
end

function platform:exit() end                                                                       --End the program

function platform:print(text) print(text) platform.output_update:invoke(text) end                  --Output text to console
function platform:info(message) if message==nil then return end                                    --Output info to console
	return platform:print("["..stdplib:get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:get_file(path,current_file)                                                      --Retrieve file via path
	if path==nil then return end
	path="system/"..path.." "
	current_file=current_file or platform.default.current_file
	local path_length,step,file_name=stdplib.root_functions.string.len(path),0,""
	for a=1,path_length do
		local char=stdplib.root_functions.string.sub(path,a,a)
		if char~="/" and char~="<" and a<path_length then
			file_name=file_name..char
		else
			if step<=0 and file_name=="root" then
				local os=platform:get_running_platform() 
				if stdplib.root_functions.string.find(stdplib.root_functions.string.lower(os),"windows") or stdplib.root_functions.string.find(stdplib.root_functions.string.lower(os),"dos") then
					current_file="C:"
				else
					current_file="/"
				end
			elseif stdplib.root_functions.string.len(file_name)>0 then
				if stdplib.root_functions.string.len(current_file)>0 then
					current_file=current_file.."/"..file_name
				else
					current_file=file_name
				end
			end
			if char=="<" then
				current_file=stdplib:get_parent_directory(current_file,1)
			end
			step=step+1
			file_name=""
		end
	end
	return current_file
end

function platform:file_exists(file)                                                                --Check if file exists
	return fs.existsSync(platform:get_file(file))
end
function platform:get_sub_files(file)                                                              --Get a list of sub files
	return fs.readdirSync(platform:get_file(file))
end
function platform:get_full_path(file)                                                              --Get full path of file
	return platform:get_file(file)
end
function platform:read_lines(file)
	local lines={}
	--Code here
	return lines
end
function platform:create_file(file_name)
	if file_name==nil then return end
	
	local source,error--=love.filesystem.newFile(platform:get_file(file_name))
	
	platform:info(error)
	
	local file={
		source=source;
	}
	
	function file:write_line(data)
		--file.source:write(data.."\r\n")
	end
	function file:clear()
		--file.source:flush()
	end
	function file:open(file_mode)
		--file.source:open(file_mode)
	end
	function file:close()
		--file.source:close()
	end
	
	return file
end

function platform:require(file)                                                                    --Get a value from a lua file
	local success,lib=pcall(require,platform:get_file(file))
	if success==false then
		platform:info(lib)
	end
	return lib
end

function platform:yield(duration) timer.sleep(duration) end                                        --Yield the entire thread
function platform:get_tick() return os.clock()-platform.start_tick end                             --Get the current clock tick
function platform:get_frame_rate() return 0 end                                                    --Get the current FPS

function platform:get_joystick_key_press(joystick_id,...)                                          --Check if joystick button is pressed
	local state=false
	--code here
	return state
end
function platform:get_key_press(...) return false end                                              --Check if keyboard button is pressed
function platform:get_mouse_key_press(...) return false end                                        --Check if mouse button is pressed
function platform:update_pointers()                                                                --Update pointers
	local pointers={}
	--code here
	platform.pointers:set_value(pointers)
end

function platform:set_filter_mode(min_mode,max_mode,anistropy)                                     --Set image scaling filter mode
	--code here
end

function platform:set_blend_mode(mode,alpha_mode)                                                  --Set blend mode
	--code here
end

function platform:set_cursor_visibility(state)                                                     --Set cursor visibility
	--code here
end

function platform:get_buffer_resolution(buffer)                                                    --Get current screen resolution
	local resolution={x=0,y=0}
	if buffer~=nil then
		resolution={x=0,y=0}
	else
		platform.screen_resolution:set_value(resolution)
	end
	return resolution
end

function platform:get_max_resolution()                                                             --Get max supported screen resolution
	return {x=0,y=0}
end

function platform:load_source(file,file_type,properties)                                           --Load asset in memory for future reference
	if file==nil or file_type==nil then return end
	properties=properties or {}
	--[[
	if file_type==platform.enum.file_type.image then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(love.graphics.newImage,platform:get_file(file))
			if success==false then
				platform:info("Failed to load image: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.font then
		if platform.assets[file]==nil then
			local font={}
			for i=6,108 do
				success,font[i]=pcall(love.graphics.newFont,platform:get_file(file),i)
				if success==false then
					platform:info("Failed to load font: "..file)
					break
				end
			end
			platform.assets[file]=font
		end
	elseif file_type==platform.enum.file_type.audio then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(love.sound.newSoundData,platform:get_file(file))
			if success==false then
				platform:info("Failed to load audio: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.model then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(iqm.load,platform:get_file(file))
			if success==false then
				platform:info("Failed to load model: "..file)
			end
		end
	end
	--]]
	return platform.assets[file]
end
function platform:load_sources(files) if files==nil or type(file)~="table" then return end         --Load multiple files
	for _,file in ipairs(files) do platform:load_source(file[1],file[2],file[3]) end
end
function platform:unload_source(file) platform.assets[file]=nil end                                --Unload asset
function platform:clear_sources() platform.assets={} end                                           --Unload every assets

function platform:create_buffer(...)                                                               --Create an external buffer
	local args={...}
	local buffer
	return buffer
end
function platform:set_current_buffer(...)                                                          --Begin drawing to a buffer
	--code here
end
function platform:clear_buffer(color,opacity,active_buffers)                                       --Clears buffer
	--code here
end

function platform:create_shader(fragment_code,vertex_code)                                         --Create a new shader
	return nil
end
function platform:set_current_shader(shader)                                                       --Set current shader
	--code here
end
function platform:get_shader_uniform_location(shader,uniform_name)                                 --Get uniform location from shader
	return nil
end
function platform:set_shader_value(shader,uniform_location,type,value,size)                        --Set shader uniform value
	if shader==nil or type==nil or values==nil then return end
	if type==platform.enum.value_type.int then
		--shader:send(uniform_location,math_functions.round(value),size)
	elseif type==platform.enum.value_type.float then
		--shader:send(uniform_location,value,size)
	elseif type==platform.enum.value_type.matrix_4 then
		--shader:send(uniform_location,value)
	end
end

function platform:render_image(source,position,size,rotation,wrap,background_color,source_color,filter_mode,anistropy,buffer) --Render image to the buffer
	--code here
end

function platform:get_text_size(text,font,font_size)
	return {x=0,y=0}
end
function platform:render_text(text,position,wrap,wrapped,color,alignment,font,font_size,buffer)    --Render text to the screen
	--code here
end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio_object={
		source--=love.audio.newSource(properties.source);
	}
	function audio_object:set_source(source)
		--audio_object.source=love.audio.newSource(source)
	end
	function audio_object:set_state(state)
		if state==platform.enum.audio_state.play then
			--audio_object.source:play()
		elseif state==platform.enum.audio_state.stop then
			--audio_object.source:stop()
		elseif state==platform.enum.audio_state.pause then
			--audio_object.source:pause()
		end
	end
	function audio_object:play()
		--audio_object.source:play()
	end
	function audio_object:pause()
		--audio_object.source:pause()
	end
	function audio_object:resume()
		--audio_object.source:resume()
	end
	function audio_object:stop()
		--audio_object.source:stop()
	end
	function audio_object:set_position(position) position=position or 0
		--audio_object.source:seek(position)
	end
	function audio_object:set_loop(state) state=state or false
		--audio_object.source:setLooping(state)
	end
	function audio_object:set_pitch(pitch) pitch=pitch or 1
		--audio_object.source:setPitch(pitch)
	end
	function audio_object:set_volume(volume) volume=volume or 1
		--audio_object.source:setVolume(volume)
	end
	function audio_object:get_source() return source end
	function audio_object:get_playing_state()
		return false
	end
	function audio_object:get_pause()
		return false
	end
	function audio_object:get_position()
		return 0
	end
	function audio_object:get_duration()
		return 0
	end
	function audio_object:get_loop()
		return false
	end
	function audio_object:get_volume()
		return 0
	end
	function audio_object:get_pitch()
		return 0
	end
	
	--audio_object:play();audio_object:pause();
	audio_object:set_volume(properties.volume)
	audio_object:set_position(properties.position)
	audio_object:set_pitch(properties.pitch)
	audio_object:set_loop(properties.loop)
	
	return audio_object
end

function platform:set_screen_mode(mode)
	if mode~=nil then
		if mode==platform.enum.screen_mode.full_screen and platform.current_screen_mode.value~=mode then
			--love.window.setFullscreen(true,"exclusive")
		elseif mode==platform.enum.screen_mode.window and platform.current_screen_mode.value~=mode then
			--love.window.setFullscreen(false)
		end
		platform.current_screen_mode:set_value(mode)
	end
end
function platform:set_window(resolution,title,frame_rate)
	resolution=resolution or {x=640,y=480}
	--code here
end
function platform:set_window_position(position)
	if position~=nil then
		--love.window.setPosition(position.x,position.y,1)
	end
end

--____________________________________Setup____________________________________
function platform:initialize(properties)
	properties=properties or {}
	
	platform:set_filter_mode(platform.enum.filter_mode.nearest,platform.enum.filter_mode.nearest,0) 
	platform:set_window(properties.screen_resolution,properties.window_title,properties.frame_rate)
	platform:set_screen_mode(properties.screen_mode)
	platform:set_cursor_visibility(properties.cursor_visible)
	
	--::::::::::::::::::::[Callbacks]::::::::::::::::::::
	--[[
	function love.keypressed(key) platform.key_state:invoke({key=key,state=true}) end
	function love.keyreleased(key) platform.key_state:invoke({key=key,state=false}) end
	function love.joystickpressed(joystick,key)
		local id,_=joystick:getID()
		platform.joystick_key_state:invoke({id=id or 1,key=key,state=true})
	end
	function love.joystickreleased(joystick,key)
		local id,_=joystick:getID()
		platform.joystick_key_state:invoke({id=id or 1,key=key,state=false})
	end
	function love.textinput(text) platform.text_input:invoke(text) end
	function love.touchpressed(id,x,y) platform:update_pointers() end
	function love.touchreleased(id,x,y) platform:update_pointers() end
	function love.mousepressed(x,y,id)
		platform.mouse_key_state:invoke({key=id,state=true})
	end
	function love.mousereleased(x,y,id)
		platform.mouse_key_state:invoke({key=id,state=false})
	end
	function love.mousemoved(x,y,dx,dy)
		platform.mouse_position:set_value({x=x,y=y})
		platform.mouse_moved:invoke({x=dx,y=dy})
	end
	function love.touchmoved() platform:update_pointers() end
	function love.update(...) platform.update_stepped:invoke(...) end
	function love.resize(x,y) platform.screen_resolution:set_value({x=x,y=y}) end

	platform:get_buffer_resolution()

	for i=6,72 do
		_,platform.default.font[i]=pcall(love.graphics.newFont,i)
	end

	--::::::::::::::::::::[Rendering]::::::::::::::::::::
	function love.draw(...)
		platform.render_stepped:invoke(...)
		--platform.update_stepped:invoke(...)
		--love.graphics.print("FPS: "..tostring(platform:get_frame_rate()))
	end
	--]]
	
	while true do
		platform.update_stepped:invoke()
	end
end
--_____________________________________________________________________________

return platform