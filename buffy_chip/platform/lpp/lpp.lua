--________________________________Dependencies_________________________________
local clock=Timer.new()
--_____________________________________________________________________________

--_______________________________Minor functions_______________________________
local math_functions={
	rad=math.rad;
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
			for i,current_bind in ipairs(signal.binds) do
				if current_bind==self then table.remove(signal.binds,i);break end
			end
		end
		table.insert(signal.binds,#signal.binds+1,bind)
		return bind
	end
	function signal:invoke(...)
		for _,bind in ipairs(signal.binds) do bind:action(...) end
	end
	return signal
end

function create_property(value)
	local property={value=value;binds={};}
	function property:invoke(custom_value)
		for _,bind in ipairs(self.binds) do
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
		self.binds[#self.binds+1]=bind
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
	_target="lua_player_plus";
	_version={0,2,5};
	
	start_tick=Timer.getTime(clock)/1000;
	delta_time=0;
	
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
		font={};
	};
}

function platform:get_running_platform()                                                           --Get the platform specs
	return {operating_system="3DS System";bits=32;}
end

function platform:execute_command(code) if code==nil then return end                               --Execute OS specific commands
	local handle=io.popen(code)
	local output=handle:read("*a")
	handle:close()
	return output
end

function platform:exit() love.event.quit() end                                                     --End the program

function platform:print(text) print(text) platform.output_update:invoke(text) end                  --Output text to console
function platform:info(message) if message==nil then return end                                    --Output info to console
	return platform:print("["..get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:file_exists(file) return System.doesFileExist("/3ds/Kirby_Dimensions/"..file) end                        --Check if file exists

function platform:require(file) return dofile("/3ds/Kirby_Dimensions/"..file..".lua") end                                           --Get a value from a lua file

function platform:yield(duration) end                                   --Yield the entire thread
function platform:get_tick() return (Timer.getTime(clock)/1000)-platform.start_tick end                             --Get the current clock tick
function platform:get_frame_rate() return math_functions.floor(1/platform.delta_time) end                                         --Get the current FPS

function platform:get_joystick_key_press(joystick_id,key)                                          --Check if joystick button is pressed
	local state=false
	
	return state
end
function platform:get_key_press(key) return Controls.check(Controls.read(),key) end                          --Check if keyboard button is pressed
function platform:get_mouse_key_press(key) end                       --Check if mouse button is pressed
function platform:update_pointers()                                                                --Update pointers
	local pointers={}
	--[[
	local mouse_x,mouse_y=love.mouse.getPosition()
	if love.mouse.isDown(1)==true and love.mouse.isDown(2)==true then
		table.insert(pointers,#pointers+1,{id=1,position={x=mouse_x,y=mouse_y}})
	end
	--]]
	local touch_x,touch_y=Controls.readTouch()
	table.insert(pointers,#pointers+1,{id=1,position={x=touch_x,y=touch_y}})
	platform.pointers:set_value(pointers)
end

function platform:set_filter_mode(min_mode,max_mode,anistropy)                                     --Set image scaling filter mode
	
end

function platform:set_blend_mode(mode,alpha_mode)                                                  --Set blend mode
	
end

function platform:set_cursor_visibility(state)                                                     --Set cursor visibility
	
end

function platform:get_buffer_resolution(buffer)                                                    --Get current screen resolution
	local resolution={x=400,y=240}
	if buffer~=nil then
		resolution={x=Graphics.getImageWidth(buffer),y=Graphics.getImageHeight(buffer)}
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
			success,platform.assets[file]=pcall(Graphics.loadImage,"/3ds/Kirby_Dimensions/"..file)
			if success==false then
				platform:info("Failed to load image: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.font then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(Font.load,"/3ds/Kirby_Dimensions/"..file)
			if success==false then
				platform:info("Failed to load image: "..file)
			end
		end
	elseif file_type==platform.enum.file_type.audio then
		if platform.assets[file]==nil then
			--success,platform.assets[file]=pcall(Sound.openWav,file,properties.stream)
			platform.assets[file]="/3ds/Kirby_Dimensions/"..file
			--[[
			if success==false then
				platform:info("Failed to load audio: "..file)
			end
			--]]
		end
	elseif file_type==platform.enum.file_type.model then
		if platform.assets[file]==nil then
			success,platform.assets[file]=pcall(Render.loadObject,"/3ds/Kirby_Dimensions/"..file)
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
function platform:unload_source(file) platform.assets[file]=nil end                                --Unload asset
function platform:clear_sources() platform.assets={} end                                           --Unload every assets

function platform:create_buffer(...)                                                               --Create an external buffer
	local args={...}
	local buffer
	if #args<=3 then
		buffer=thread.platform:load_source("assets/textures/3ds_top_screen_buffer.png")
	else
		buffer=thread.platform:load_source("assets/textures/3ds_top_screen_buffer.png")
	end
	return buffer
end
function platform:set_current_buffer(...)                                                          --Begin drawing to a buffer
	
end
function platform:clear_buffer(color,opacity,active_buffers)                                       --Clears buffer
	
end

function platform:create_shader(fragment_code,vertex_code)                                         --Create a new shader
	
end
function platform:set_current_shader(shader)                                                       --Set current shader
	
end
function platform:get_shader_uniform_location(shader,uniform_name)                                 --Get uniform location from shader
	
end
function platform:set_shader_value(shader,uniform_location,type,value,size)                        --Set shader uniform value
	if shader==nil or type==nil or values==nil then return end
	if type==platform.enum.value_type.int then
		
	elseif type==platform.enum.value_type.float then
		
	elseif type==platform.enum.value_type.matrix_4 then
		
	end
end

function set_depth_test(depth) end                                   --Set current depth test
function set_culling(culling) end                                     --Set current culling

function platform:render_image(source,position,size,rotation,wrap,color,opacity,filter_mode,anistropy,buffer) --Render image to the buffer
	if source==nil or position==nil or size==nil then return end
	local source_area,destination_area={x=0,y=0;width=source.width,height=source.height},{x=position.x,y=position.y;width=size.x,height=size.y}
	local origin=Vector2(0,0)
	if wrap~=nil then
		if position.x+size.x<wrap.x1 or position.x>wrap.x2 or position.y+size.y<wrap.y1 or position.y>wrap.y2 then return end
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
	Graphics.drawImageExtended(
		destination_area.x,destination_area.y,
		source_area.x,source_area.y,
		source_area.width,source_area.height,
		rotation,
		size.x/Graphics.getImageWidth(test),size.y/Graphics.getImageHeight(source),
		source,
		Color.new(color.r*255,color.g*255,color.b*255,(1-opacity)*255)
	)
end

function platform:get_text_size(text,font,font_size)
	return {x=font[font_size]:getWidth(text),y=font[font_size]:getHeight()}
end
function platform:render_text(text,position,wrap,wrapped,color,opacity,alignment,font,font_size,buffer)    --Render text to the screen
	font=font or platform.default.font
	Font.setPixelSizes(font,font_size) 
	Font.print(font,position.x,position.y,text,Color.new(color.r*255,color.g*255,color.b*255,(1-opacity)*255),TOP_SCREEN)
end

function platform:create_model(properties)
	local model_object={
		source=properties.source;
		position=properties.position or cpml.vec3(0,0,0);
		size=properties.size or cpml.vec3(1,1,1);
		orientation=properties.orientation or cpml.quat();
	}
	
	return model_object
end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio_object={
		source=Sound.openWav(properties.source,properties.stream)
	}
	function audio_object:set_source(source,stream)
		audio_object.source=Sound.openWav(source,stream)
	end
	function audio_object:set_state(state)
		if state==platform.enum.audio_state.play then
			Sound.play(audio_object.source)
		elseif state==platform.enum.audio_state.stop then
			Sound.stop(audio_object.source)
		elseif state==platform.enum.audio_state.pause then
			Sound.pause(audio_object.source)
		end
	end
	function audio_object:play()
		Sound.play(audio_object.source)
	end
	function audio_object:pause()
		Sound.pause(audio_object.source)
	end
	function audio_object:resume()
		Sound.resume(audio_object.source)
	end
	function audio_object:stop()
		Sound.stop(audio_object.source)
	end
	function audio_object:set_position(position) position=position or 0
		
	end
	function audio_object:set_loop(state) state=state or false
		--Sound.play(audio_object.source,state)
	end
	function audio_object:set_pitch(pitch) pitch=pitch or 1
		
	end
	function audio_object:set_volume(volume) volume=volume or 1
		
	end
	function audio_object:get_source() return audio_object.source end
	function audio_object:get_playing_state()
		return Sound.isPlaying(audio_object.source)
	end
	function audio_object:get_pause()
		return false
	end
	function audio_object:get_position()
		return Sound.getTime(audio_object.source)
	end
	function audio_object:get_duration()
		return Sound.getTotalTime(audio_object.source)
	end
	function audio_object:get_loop()
		return false
	end
	function audio_object:get_volume()
		return 1
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
			
		elseif mode==platform.enum.screen_mode.window and platform.current_screen_mode.value~=mode then
			
		end
		platform.current_screen_mode:set_value(mode)
	end
end
function platform:set_window(resolution,title,frame_rate)
	resolution=resolution or {x=400,y=240}
	local vsync=false
	if frame_rate~=nil and frame_rate<=60 then vsync=true end
	
end
function platform:set_window_position(position)
	if position~=nil then
		
	end
end

--____________________________________Setup____________________________________
function platform:initialize(properties)
	properties=properties or {}
	
	Graphics.init()
	Sound.init()
	
	platform:set_filter_mode(platform.enum.filter_mode.nearest,platform.enum.filter_mode.nearest,0) 
	platform:set_window(properties.screen_resolution,properties.window_title,properties.frame_rate)
	platform:set_screen_mode(properties.screen_mode)
	platform:set_cursor_visibility(properties.cursor_visible)
	
	--::::::::::::::::::::[Callbacks]::::::::::::::::::::
	

	platform:get_buffer_resolution()

	--::::::::::::::::::::[Rendering]::::::::::::::::::::
	local pre_tick=platform:get_tick()
	local tick=platform:get_tick()
	while true do
		tick=platform:get_tick()
		platform.delta_time=tick-pre_tick
		pre_tick=tick
		--Screen.refresh()
		platform.update_stepped:invoke()
		Graphics.initBlend(TOP_SCREEN)
		platform.render_stepped:invoke()
		Screen.flip()
		Graphics.termBlend()
		Screen.debugPrint(0,0,"FPS: "..tostring(platform:get_frame_rate()),Color.new(255,255,255),TOP_SCREEN)
		if Controls.check(Controls.read(),KEY_HOME) then
			System.exit()
		end
		Screen.waitVblankStart()
	end
end
--_____________________________________________________________________________

return platform