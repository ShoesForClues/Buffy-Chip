--________________________________Dependencies_________________________________
local root_functions={
	math={
		floor=math.floor;
		ceil=math.ceil;
		abs=math.abs;
		rad=math.rad;
		random=math.random;
		max=math.max;
		min=math.min;
		pi=math.pi;
	};
	string={
		len=string.len;
		sub=string.sub;
		format=string.format;
		upper=string.upper;
		lower=string.lower;
		byte=string.byte;
		char=string.char;
		find=string.find;
	};
	table={
		unpack=unpack;
		insert=table.insert;
		remove=table.remove;
	};
};

if _VERSION=="Lua 5.3" then
	root_functions.table.unpack=table.unpack
end

function create_signal()
	local signal={
		binds={};
	}
	function signal:attach(action,thread)
		if action==nil or type(action)~="function" then return end
		local bind={action=action;thread=thread}
		function bind:detach()
			for i,current_bind in pairs(signal.binds) do
				if current_bind==bind then root_functions.table.remove(signal.binds,i);break end
			end
		end
		if thread~=nil then
			thread.killed:attach(function()
				bind:detach()
			end)
		end
		signal.binds[#signal.binds+1]=bind
		return bind
	end
	function signal:invoke(...) local values={...}
		for _,bind in pairs(signal.binds) do
			--[[
			thread:create_thread(function(thread)
				bind.action(root_functions.table.unpack(values))
			end)
			--]]
			if bind.thread==nil or bind.thread.runtime.run_state.value==true then
				bind.action(root_functions.table.unpack(values))
			end
		end
	end
	return signal
end

function create_property(value)
	local property={
		value=value;
		binds={};
	}
	function property:invoke(custom_value)
		local old_value=self.value
		for _,bind in pairs(self.binds) do
			if type(bind.action)=="function" then
				--thread:create_thread(function(thread) bind.action(custom_value,self.value) end)
				if bind.thread==nil or bind.thread.runtime.run_state.value==true then
					bind.action(custom_value,old_value)
				end
			end
		end
	end
	function property:set_value(value)
		if self.value==value then return end
		self:invoke(value)
		self.value=value
	end
	function property:add_value(value,index)
		if value~=nil and type(self.value)=="table" then
			self:invoke(value)
			self.value[index or #self.value+1]=value
		end
	end
	function property:remove_value(index)
		if index~=nil and type(self.value)=="table" then
			self:invoke(self.value[index])
			root_functions.table.remove(self.value,index)
		end
	end
	function property:attach(action,thread)
		if action==nil or type(action)~="function" then return end
		local bind={action=action;thread=thread}
		function bind:detach()
			for i,current_bind in pairs(property.binds) do
				if current_bind==bind then root_functions.table.remove(property.binds,i);break end
			end
		end
		if thread~=nil then
			thread.killed:attach(function()
				bind:detach()
			end)
		end
		property.binds[#property.binds+1]=bind
		return bind
	end
	return property
end

function get_time_stamp(seconds)
	seconds=root_functions.math.floor(tonumber(seconds))
	if seconds <= 0 then
		return "00:00:00";
	else
		local hours=root_functions.string.format("%02.f",root_functions.math.floor(seconds/3600));
		local mins=root_functions.string.format("%02.f",root_functions.math.floor(seconds/60-(hours*60)));
		local secs=root_functions.string.format("%02.f",root_functions.math.floor(seconds-hours*3600-mins*60));
		return hours..":"..mins..":"..secs
	end
end

function get_parent_directory(path,parent_index)
	if path==nil then return "" end
	parent_index=parent_index or 1
	local current_index=0
	local path_length=root_functions.string.len(path)
	local parent_length=0
	for i=1,path_length do
		if current_index<parent_index then
			local char=root_functions.string.sub(path,path_length+1-i,path_length+1-i)
			if char=="/" or char=="\\" then
				current_index=current_index+1
				parent_length=path_length+1-i
			end
		else
			break
		end
	end
	return root_functions.string.sub(path,1,parent_length)
end
--_____________________________________________________________________________

local platform={
	_target="love_11";
	_version={0,3,6};
	_platform={operating_system="unknown";bits=32;};
	_config={
		hide_info=false;
	};
	
	start_tick=love.timer.getTime();
	
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
	
	text_input=create_signal();
	key_state=create_signal();
	joystick_key_state=create_signal();
	mouse_key_state=create_signal();
	mouse_moved=create_signal();
	wheel_scrolled=create_signal();
	mouse_position=create_property({x=0,y=0});
	pointers=create_property({});

	update_stepped=create_signal();
	render_stepped=create_signal();
	
	current_screen_mode=create_property("WINDOW");
	screen_resolution=create_property({x=0,y=0});
	
	output_update=create_signal();
	
	default={
		font={};
		current_file="";
	};
}

function platform:get_running_platform()                                                           --Get the platform specs
	platform._platform={operating_system=love.system.getOS();bits=32;}
	return platform._platform
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

function platform:exit() love.event.quit() end                                                     --End the program

function platform:print(text) print(text) platform.output_update:invoke(text) end                  --Output text to console
function platform:info(message)                                                                    --Output info to console
	if message==nil or platform._config.hide_info==true then return end
	return platform:print("["..get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:get_file(path,current_file)                                                      --Retrieve file via path
	if path==nil then return end
	path=path.." "
	current_file=current_file or platform.default.current_file
	local path_length,step,file_name=root_functions.string.len(path),0,""
	for a=1,path_length do
		local char=root_functions.string.sub(path,a,a)
		if char~="/" and char~="<" and a<path_length then
			file_name=file_name..char
		else
			if step<=0 and file_name=="root" then
				if root_functions.string.find(root_functions.string.lower(platform._platform.operating_system),"windows") or root_functions.string.find(root_functions.string.lower(platform._platform.operating_system),"dos") then
					current_file="C:"
				else
					current_file="/"
				end
			elseif root_functions.string.len(file_name)>0 then
				if root_functions.string.len(current_file)>0 then
					current_file=current_file.."/"..file_name
				else
					current_file=file_name
				end
			end
			if char=="<" then
				current_file=get_parent_directory(current_file,1)
			end
			step=step+1
			file_name=""
		end
	end
	return current_file
end

function platform:file_exists(file)                                                                --Check if file exists
	return love.filesystem.getInfo(platform:get_file(file))~=nil
end
function platform:get_sub_files(file)                                                              --Get a list of sub files
	return love.filesystem.getDirectoryItems(platform:get_file(file))
end
function platform:get_full_path(file)                                                              --Get full path of file
	return love.filesystem.getRealDirectory(platform:get_file(file))
end
function platform:read_file(file,yield_call)
	if platform:file_exists(file)==false then return "" end
	local data=""
	for line in love.filesystem.lines(platform:get_file(file)) do
		data=data..line
		if yield_call~=nil then
			yield_call()
		end
	end
	return data
end
function platform:read_lines(file)
	local lines={}
	for line in love.filesystem.lines(platform:get_file(file)) do
		lines[#lines+1]=line
	end
	return lines
end
function platform:create_file(file_name)
	if file_name==nil then return end
	
	local source,error=love.filesystem.newFile(platform:get_file(file_name))
	
	if error~=nil then
		platform:info(error)
	end
	
	local file={
		source=source;
	}
	
	function file:write_line(data)
		file.source:write(data.."\r\n")
	end
	function file:clear()
		file.source:flush()
	end
	function file:open(file_mode)
		file.source:open(file_mode)
	end
	function file:close()
		file.source:close()
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

function platform:yield(duration) love.timer.sleep(duration) end                                   --Yield the entire thread
function platform:get_tick() return love.timer.getTime()-platform.start_tick end                   --Get the current clock tick
function platform:get_frame_rate() return love.timer.getFPS() end                                  --Get the current FPS

function platform:get_joystick_key_press(joystick_id,...)                                          --Check if joystick button is pressed
	local state=false
	for id,joystick in pairs(love.joystick.getJoysticks()) do
		if joystick_id==id then
			state=joystick:isDown(...) or false
		end
	end
	return state
end
function platform:get_key_press(...) return love.keyboard.isDown(...) end                          --Check if keyboard button is pressed
function platform:get_mouse_key_press(...) return love.mouse.isDown(...) end                       --Check if mouse button is pressed
function platform:update_pointers()                                                                --Update pointers
	local pointers={}
	local mouse_x,mouse_y=love.mouse.getPosition()
	--[[
	if love.mouse.isDown(1)==true and love.mouse.isDown(2)==true then
		table.insert(pointers,#pointers+1,{id=1,position={x=mouse_x,y=mouse_y}})
	end
	--]]
	for _,id in pairs(love.touch.getTouches()) do
		local touch_x,touch_y=love.touch.getPosition(id)
		table.insert(pointers,#pointers+1,{id=id,position={x=touch_x,y=touch_y}})
	end
	platform.pointers:set_value(pointers)
end

function platform:set_filter_mode(min_mode,max_mode,anistropy)                                     --Set image scaling filter mode
	love.graphics.setDefaultFilter(min_mode,max_mode,anistropy)
end

function platform:set_blend_mode(mode,alpha_mode)                                                  --Set blend mode
	love.graphics.setBlendMode(mode,alphamode)
end

function platform:set_cursor_visibility(state)                                                     --Set cursor visibility
	love.mouse.setVisible(state)
end

function platform:set_cursor_lock(state)                                                           --Set cursor lock
	love.mouse.setRelativeMode(state)
end

function platform:get_buffer_resolution(buffer)                                                    --Get current screen resolution
	local resolution={x=love.graphics.getWidth(),y=love.graphics.getHeight()}
	if buffer~=nil then
		resolution={x=buffer:getWidth(),y=buffer:getHeight()}
	else
		platform.screen_resolution:set_value(resolution)
	end
	return resolution
end

function platform:get_max_resolution()                                                             --Get max supported screen resolution
	if love.window==nil then return {x=0,y=0} end
	local modes=love.window.getFullscreenModes()
	local max_mode=modes[1]
	for _,mode in pairs(modes) do
		if mode.width>max_mode.width and mode.height>max_mode.height then
			max_mode=mode
		end
	end
	return {x=max_mode.width,y=max_mode.height}
end

function platform:load_source(file,file_type,properties)                                           --Load asset in memory for future reference
	if file==nil or file_type==nil then return end
	properties=properties or {}
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
	return platform.assets[file]
end
function platform:load_sources(files) if files==nil or type(file)~="table" then return end         --Load multiple files
	for _,file in ipairs(files) do platform:load_source(file[1],file[2],file[3]) end
end
function platform:unload_source(file)                                                              --Unload asset
	if platform.assets[file]~=nil then
		platform.assets[file]:release()
		platform.assets[file]=nil
	end
end
function platform:clear_sources()                                                                  --Unload every assets
	for i,_ in pairs(platform.assets) do
		platform:unload_source(i)
	end
end

function platform:create_buffer(...)                                                               --Create an external buffer
	local args={...}
	local buffer=love.graphics.newCanvas(...)
	return buffer
end
function platform:set_current_buffer(...)                                                          --Begin drawing to a buffer
	love.graphics.setCanvas(...)
end
function platform:clear_buffer(color,opacity,active_buffers)                                       --Clears buffer
	love.graphics.clear({color.r,color.g,color.b,(1-opacity)},unpack(active_buffers))
end

function platform:render_image(source,position,size,rotation,wrap,background_color,source_color,filter_mode,anistropy,buffer) --Render image to the buffer
	if position==nil or size==nil or source==love.graphics.getCanvas() then return end
	if wrap~=nil then
		if position.x+size.x<wrap.x1 or position.x>wrap.x2 or position.y+size.y<wrap.y1 or position.y>wrap.y2 then return end
		love.graphics.setScissor(wrap.x1,wrap.y1,wrap.x2-wrap.x1,wrap.y2-wrap.y1)
	end
	love.graphics.setColor(background_color.r,background_color.g,background_color.b,(1-background_color.a))
	love.graphics.rectangle("fill",position.x,position.y,size.x,size.y)
	if source~=nil then
		source:setFilter(filter_mode or platform.enum.filter_mode.nearest,filter_mode or platform.enum.filter_mode.nearest,anistropy or 0)
		love.graphics.setColor(source_color.r,source_color.g,source_color.b,(1-source_color.a))
		love.graphics.draw(
			source,
			position.x,position.y,root_functions.math.rad(rotation),
			size.x/source:getWidth(),size.y/source:getHeight()
		)
	end
	love.graphics.setScissor()
	love.graphics.setColor(1,1,1,1)
end

function platform:get_text_size(text,font,font_size)
	local size={x=font[font_size]:getWidth(text),y=font[font_size]:getHeight()}
	if text==nil or font==nil or font_size==nil then
		size={x=0,y=0}
	end
	return size
end
function platform:render_text(text,position,wrap,wrapped,color,alignment,font,font_size,buffer)    --Render text to the screen
	font=font or platform.default.font
	local text_size=platform:get_text_size(text,font,font_size)
	local wrap_center={x=(wrap.x1+wrap.x2)/2,y=(wrap.y1+wrap.y2)/2}
	if alignment.x=="center" then
		position.x=wrap_center.x-(text_size.x/2)
	elseif alignment.x=="right" then
		position.x=wrap.x2-text_size.x
	end
	if alignment.y=="center" then
		position.y=wrap_center.y-(text_size.y/2)
	elseif alignment.y=="bottom" then
		position.y=wrap.y2-text_size.y
	end
	if wrapped==true and wrap~=nil then
		love.graphics.setScissor(wrap.x1,wrap.y1,wrap.x2-wrap.x1,wrap.y2-wrap.y1)
	end
	if color~=nil then
		love.graphics.setColor(color.r,color.g,color.b,(1-color.a))
	end
	if font[font_size]~=nil then
		font[font_size]:setFilter(platform.enum.filter_mode.nearest,platform.enum.filter_mode.nearest,0)
		love.graphics.setFont(font[font_size])
		love.graphics.printf(text,position.x,position.y,wrap.x2-wrap.x1,"left")
	end
	love.graphics.setScissor()
	love.graphics.setColor(1,1,1,1)
end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio_object={
		source=love.audio.newSource(properties.source);
	}
	function audio_object:set_source(source)
		audio_object.source=love.audio.newSource(source)
	end
	function audio_object:set_state(state)
		if state==platform.enum.audio_state.play then
			audio_object.source:play()
		elseif state==platform.enum.audio_state.stop then
			audio_object.source:stop()
		elseif state==platform.enum.audio_state.pause then
			audio_object.source:pause()
		end
	end
	function audio_object:play()
		audio_object.source:play()
	end
	function audio_object:pause()
		audio_object.source:pause()
	end
	function audio_object:resume()
		audio_object.source:resume()
	end
	function audio_object:stop()
		audio_object.source:stop()
	end
	function audio_object:set_position(position) position=position or 0
		audio_object.source:seek(position)
	end
	function audio_object:set_loop(state) state=state or false
		audio_object.source:setLooping(state)
	end
	function audio_object:set_pitch(pitch) pitch=pitch or 1
		audio_object.source:setPitch(pitch)
	end
	function audio_object:set_volume(volume) volume=volume or 1
		audio_object.source:setVolume(volume)
	end
	function audio_object:get_source() return source end
	function audio_object:get_playing_state()
		return audio_object.source:isPlaying()
	end
	function audio_object:get_pause()
		return not audio_object.source:isPlaying()
	end
	function audio_object:get_position()
		return audio_object.source:tell()
	end
	function audio_object:get_duration()
		return audio_object.source:getDuration()
	end
	function audio_object:get_loop()
		return audio_object.source:isLooping()
	end
	function audio_object:get_volume()
		return audio_object.source:getVolume()
	end
	function audio_object:get_pitch()
		return audio_object.source:getPitch()
	end
	
	--audio_object:play();audio_object:pause();
	audio_object:set_volume(properties.volume)
	audio_object:set_position(properties.position)
	audio_object:set_pitch(properties.pitch)
	audio_object:set_loop(properties.loop)
	
	return audio_object
end

function platform:set_error_handler(handler)
	function love.errorhandler(error_message)
		return handler(tostring(error_message))
	end
end

function platform:set_screen_mode(mode)
	if mode~=nil and love.window~=nil then
		if mode==platform.enum.screen_mode.full_screen and platform.current_screen_mode.value~=mode then
			love.window.setFullscreen(true,"exclusive")
		elseif mode==platform.enum.screen_mode.window and platform.current_screen_mode.value~=mode then
			love.window.setFullscreen(false)
		end
		platform.current_screen_mode:set_value(mode)
	end
end
function platform:set_window(resolution,title,frame_rate)
	if love.window==nil then return end
	resolution=resolution or {x=640,y=480}
	local vsync=false
	if frame_rate~=nil and frame_rate<=60 then vsync=true end
	love.window.setTitle(title or "")
	love.window.setMode(
		resolution.x,resolution.y,
		{resizable=true,minwidth=320,minheight=200,vsync=vsync}
	)
end
function platform:set_window_position(position)
	if position~=nil and love.window~=nil then
		love.window.setPosition(position.x,position.y,1)
	end
end

--____________________________________Setup____________________________________
function platform:initialize(properties)
	properties=properties or {}
	
	platform:get_running_platform()
	
	platform:set_filter_mode(platform.enum.filter_mode.nearest,platform.enum.filter_mode.nearest,0) 
	platform:set_window(properties.screen_resolution,properties.window_title,properties.frame_rate)
	platform:set_screen_mode(properties.screen_mode)
	platform:set_cursor_visibility(properties.cursor_visible)
	platform:set_cursor_lock(properties.cursor_lock)
	
	--::::::::::::::::::::[Callbacks]::::::::::::::::::::
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
	function love.wheelmoved(x,y) platform.wheel_scrolled:invoke({x=x,y=y}) end

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
end
--_____________________________________________________________________________

return platform