--________________________________Dependencies_________________________________
--_____________________________________________________________________________

--_______________________________Minor functions_______________________________
local math_functions={
	floor=math.floor;
	ceil=math.ceil;
	round=nil;
}
math_functions.round=function(num,decimal_place)
	local mult=10^(decimal_place or 0)
	return math_functions.floor(num*mult+0.5)/mult
end

function create_signal()
	local signal={
		binds={}
	}
	function signal:attach_bind(action)
		if action==nil or type(action)~="function" then return end
		local bind={action=action;}
		function bind:detach()
			for i,current_bind in pairs(signal.binds) do
				if current_bind==self then table.remove(signal.binds,i);break end
			end
		end
		table.insert(signal.binds,#signal.binds+1,bind)
		return bind
	end
	function signal:invoke(...)
		for _,bind in pairs(signal.binds) do bind:action(...) end
	end
	return signal
end

function create_property(value)
	local property={value=value;binds={};}
	function property:invoke(custom_value)
		for _,bind in pairs(self.binds) do
			if bind~=nil and bind.action~=nil and type(bind.action)=="function" then
				bind.action(custom_value or self.value)
			end
		end
	end
	function property:set_value(value)
		if self==value or self.value==value then return end
		self.value=value
		self:invoke(self.value)
	end
	function property:add_value(value,index)
		if value~=nil and type(self.value)=="table" then
			table.insert(self.value,index or #self.value+1,value)
			self:invoke(self.value)
		end
	end
	function property:remove_value(index)
		if index~=nil and type(self.value)=="table" and self.value[index]~=nil then
			table.remove(self.value,index)
			self:invoke(self.value)
		end
	end
	function property:attach_bind(action)
		if action==nil or type(action)~="function" then return end
		local bind={action=action;}
		function bind:detach() bind.action,bind=nil,nil end
		table.insert(self.binds,#self.binds+1,bind)
		return bind
	end
	return property
end

function get_time_stamp(seconds)
	seconds=math.floor(tonumber(seconds))
	if seconds <= 0 then
		return "00:00:00";
	else
		hours=string.format("%02.f",math.floor(seconds/3600));
		mins=string.format("%02.f",math.floor(seconds/60-(hours*60)));
		secs=string.format("%02.f",math.floor(seconds-hours*3600-mins*60));
		return hours..":"..mins..":"..secs
	end
end
--_____________________________________________________________________________

local platform={
	_target="raylib";
	_version={0,2,2};
	
	start_tick=os.clock();
	
	enum={
		filter_mode={
			linear=TextureFilter.BILINEAR;
			nearest=TextureFilter.POINT;
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
		};
		screen_mode={
			full_screen="FULL_SCREEN";
			window="WINDOW";
		};
		value_type={
			int=0x0b;
			float=0x0c;
			matrix=0x0d;
		};
	};
	
	assets={}; --Asset bank
	
	text_input=create_signal();
	key_state=create_signal();
	joystick_key_state=create_signal();
	mouse_key_state=create_signal();
	pointer=create_signal();
	pointers=create_property({});

	update_stepped=create_signal();
	render_stepped=create_signal();
	
	current_screen_mode=create_property("WINDOW");
	screen_resolution=create_property({x=0,y=0});
	
	output_update=create_signal();
	
	default={
		max_touches=10;
	};
}

function platform:get_running_platform()                                                           --Get the platform specs
	return {operating_system="unknown";bits=32;}
end

function platform:execute_command(code) if code==nil then return end                               --Execute OS specific commands
	local handle=io.popen(code)
	local output=handle:read("*a")
	handle:close()
	return output
end

function platform:exit() end

function platform:print(text) print(text) platform.output_update:invoke(text) end                  --Output text to console
function platform:info(message) if message==nil then return end                                    --Output info to console
	return platform:print("["..get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:file_exists(file)                                                                --Check if file exists
end

function platform:require(file) return require(file) end                                           --Get a value from a lua file

function platform:yield(duration) end                                                              --Yield the entire thread
function platform:get_tick() return os.clock()-platform.start_tick end                             --Get the current clock tick
function platform:get_frame_rate() return GetFPS() end                                                    --Get the current FPS

function platform:get_joystick_key_press(joystick_id,key)                                          --Check if joystick button is pressed
	local state=false
	
	return state
end
function platform:get_key_press(key) return IsKeyDown(key) end                                     --Check if keyboard button is pressed
function platform:get_mouse_key_press(key)                                                         --Check if mouse button is pressed
	local state=false
	if key==1 then
		state=IsMouseButtonPressed(MOUSE.LEFT_BUTTON)
	elseif key==2 then
		state=IsMouseButtonPressed(MOUSE.RIGHT_BUTTON)
	elseif key==3 then
		state=IsMouseButtonPressed(MOUSE.MIDDLE_BUTTON)
	end
	return state
end
function platform:update_pointers()                                                                --Update pointers
	local pointers={}
	local mouse_position=GetMousePosition()
	table.insert(pointers,#pointers+1,{id=1,position={x=mouse_position.x,y=mouse_position.y},state=IsMouseButtonPressed(MOUSE.LEFT_BUTTON)})
	--table.insert(pointers,#pointers+1,{id=1,position={x=touch_position.x,y=touch_position.y},state=IsMouseButtonPressed(MOUSE.LEFT_BUTTON)})
	platform.pointers:set_value(pointers)
end

function platform:set_filter_mode(min_mode,max_mode,anistropy)                                     --Set image scaling filter mode
	
end
function platform:set_cursor_visibility(state)                                                     --Set cursor visibility
	if state==true then
		ShowCursor()
	elseif state==false then
		HideCursor()
	end
end
function platform:get_buffer_resolution(buffer)                                                    --Get current screen resolution
	local resolution={x=GetScreenWidth() or 0,y=GetScreenHeight() or 0}
	if buffer~=nil then
		resolution={x=buffer.texture.width,y=buffer.texture.height}
	else
		platform.screen_resolution:set_value(resolution)
	end
	return resolution
end

function platform:load_source(file,file_type,properties)                                           --Load asset in memory for future reference
	if file==nil or file_type==nil then return end
	properties=properties or {}
	if file_type==platform.enum.file_type.image then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(LoadTexture,file)
			if success==false then
				platform:info("Failed to load image: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.font then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(LoadSpriteFont,file)
			if success==false then
				platform:info("Failed to load font: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.audio then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(LoadWave,file)
			if success==false then
				platform:info("Failed to load audio: "..file)
			end
		end
	end
	return platform.assets[file]
end
function platform:load_sources(fqiles) if files==nil or type(file)~="table" then return end         --Load multiple files
	for _,file in pairs(files) do platform:load_source(file[1],file[2],file[3]) end
end
function platform:unload_source(file) platform.assets[file]=nil end                                --Unload asset
function platform:clear_sources() platform.assets={} end                                           --Unload every assets

function platform:create_buffer(width,height)                                                      --Create an external buffer
	return LoadRenderTexture(width or platform.screen_resolution.value.x,height or platform.screen_resolution.value.y)
end
function platform:set_current_buffer(buffer)                                                       --Begin drawing to a buffer
	if buffer~=nil then
		BeginTextureMode(buffer)
	else
		EndTextureMode()
	end
end
function platform:set_current_shader(shader)                                                       --Set current shader
	if shader~=nil then
		BeginShaderMode(shader)
	else
		EndShaderMode()
	end
end
function platform:get_shader_uniform_location(shader,uniform_name)                                 --Get uniform location from shader
	return GetShaderLocation(shader,uniform_name)
end
function platform:set_shader_value(shader,uniform_location,type,value,size)                        --Set shader uniform value
	if shader==nil or type==nil or values==nil then return end
	if type==platform.enum.value_type.int then
		SetShaderValue(shader,uniform_location,math_functions.round(value),size)
	elseif type==platform.enum.value_type.float then
		SetShaderValue(shader,uniform_location,value,size)
	elseif type==platform.enum.value_type.matrix then
		SetShaderValue(shader,uniform_location,value)
	end
end
function platform:render_image(source,position,size,rotation,wrap,color,opacity,filter_mode,anistropy,buffer) --Render image to the buffer
	if source==nil or position==nil or size==nil then return end
	local source_area,destination_area=Rectangle(0,0,source.width,source.height),Rectangle(position.x,position.y,size.x,size.y)
	local origin=Vector2(0,0)
	if wrap~=nil then
		if position.x+size.x<wrap.x1 or position.x>wrap.x2 or position.y+size.y<wrap.y1 or position.y>wrap.y2 then return end
		SetTextureWrap(source,TextureWrap.CLAMP)
		if position.x<wrap.x1 then
			source_area.x=math_functions.round((wrap.x1-position.x)/size.x*source.width)
			source_area.width=math_functions.round((position.x+size.x-wrap.x1)/size.x*source.width)
			destination_area.x,destination_area.width=wrap.x1,size.x-(wrap.x1-position.x)
		end
		if position.x+size.x>wrap.x2 then
			source_area.width=math_functions.round((wrap.x2-destination_area.x)/size.x*source.width)
			destination_area.width=destination_area.width-(position.x+size.x-wrap.x2)
		end
		if position.y<wrap.y1 then
			source_area.y=math_functions.round((wrap.y1-position.y)/size.y*source.height)
			source_area.height=math_functions.round((position.y+size.y-wrap.y1)/size.y*source.height)
			destination_area.y,destination_area.height=wrap.y1,size.y-(wrap.y1-position.y)
		end
		if position.y+size.y>wrap.y2 then
			source_area.height=math_functions.round((wrap.y2-destination_area.y)/size.y*source.height)
			destination_area.height=destination_area.height-(position.y+size.y-wrap.y2)
		end
	end
	SetTextureFilter(source,filter_mode or platform.enum.filter_mode.nearest)
	DrawTexturePro(source,source_area,destination_area,origin,rotation,Color(math_functions.floor(color.r*255),math_functions.floor(color.g*255),math_functions.floor(color.b*255),math_functions.floor((1-opacity)*255)))
end
function platform:get_text_size(text,font,font_size)
	local size=MeasureTextEx(font,text,font_size,0)
	return {x=size.x,y=size.y}
end
function platform:render_text(text,position,wrap,wrapped,color,opacity,alignment,font,font_size,buffer) --Render text to the screen
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
	position.y=position.y+text_size.y
	DrawTextEx(font,text,Vector2(position.x,position.y),font_size,0,Color(math_functions.floor(color.r*255),math_functions.floor(color.g*255),math_functions.floor(color.b*255),math_functions.floor((1-opacity)*255)))
end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio_object={
		audio=LoadSoundFromWave(properties.source)
	}
	function audio_object:set_audio(source)
		audio_object.audio=LoadSoundFromWave(source)
	end
	function audio_object:set_state(state)
		if state==platform.enum.audio_state.play then
			PlaySound(audio_object.audio)
		elseif state==platform.enum.audio_state.stop then
			StopSound(audio_object.audio)
		elseif state==platform.enum.audio_state.pause then
			PauseSound(audio_object.audio)
		elseif state==platform.enum.audio_state.resume then
			ResumeSound(audio_object.audio)
		end
	end
	function audio_object:play()
		PlaySound(audio_object.audio)
	end
	function audio_object:pause()
		PauseSound(audio_object.audio)
	end
	function audio_object:resume()
		ResumeSound(audio_object.audio)
	end
	function audio_object:stop()
		StopSound(audio_object.audio)
	end
	function audio_object:set_position(position) position=position or 0
		
	end
	function audio_object:set_loop(state) state=state or false
		
	end
	function audio_object:set_pitch(pitch) pitch=pitch or 1
		SetSoundPitch(audio_object.audio,pitch)
	end
	function audio_object:set_volume(volume) volume=volume or 1
		SetSoundVolume(audio_object.audio,volume)
	end
	function audio_object:get_source() return source end
	function audio_object:get_playing_state()
		return IsSoundPlaying(audio_object.audio)
	end
	function audio_object:get_pause_state()
		return IsSoundPlaying(audio_object.audio)
	end
	function audio_object:get_position()
		return 0
	end
	function audio_object:get_duration()
		return 0
	end
	function audio_object:get_loop_state()
		return false
	end
	function audio_object:get_volume()
		return 0
	end
	function audio_object:get_pitch()
		return 1
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
			ToggleFullscreen()
		elseif mode==platform.enum.screen_mode.window and platform.current_screen_mode.value~=mode then
			ToggleFullscreen()
		end
		platform.current_screen_mode:set_value(mode)
	end
end
function platform:set_window(resolution,title,frame_rate)
	resolution=resolution or {x=640,y=480}
	InitWindow(resolution.x,resolution.y,title or "")
	SetTargetFPS(frame_rate)
end

--____________________________________Setup____________________________________
function platform:initialize(properties)
	properties=properties or {}

	platform:set_screen_mode(properties.screen_mode)
	platform:set_window(properties.screen_resolution,properties.window_title,properties.frame_rate)
	platform:set_cursor_visibility(properties.cursor_visible)

	platform:get_buffer_resolution()
	while not WindowShouldClose() do
		platform.update_stepped:invoke()
		platform:update_pointers()
		BeginDrawing()
			--ClearBackground(BLACK)
			platform.render_stepped:invoke()
			DrawFPS(10,10)
		EndDrawing()
	end
end
--_____________________________________________________________________________

return platform