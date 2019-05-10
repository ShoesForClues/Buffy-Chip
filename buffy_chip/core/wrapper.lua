--________________________________Dependencies_________________________________
local root_functions={
	math={
		floor=math.floor;
		ceil=math.ceil;
		abs=math.abs;
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

local function create_signal()
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

local function create_property(value)
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

local function get_time_stamp(seconds)
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

local function get_parent_directory(path,parent_index)
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
	_target="unknown";
	_version={0,3,8};
	_platform={operating_system="unknown";bits=32;};
	_config={
		hide_info=false;
	};
	
	start_tick=0;
	
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
			read_write="rw";
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

function platform:get_running_platform() return platform._platform end

function platform:execute_command(code,multithread) return output "" end

function platform:exit() end

function platform:print(text)
	if message==nil then return end
	print(text) platform.output_update:invoke(text)
end

function platform:info(message)
	if message==nil then return end
	return platform:print("["..get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:warn(message)
	if message==nil then return end
	return platform:print("["..get_time_stamp(platform:get_tick()).."][WARNING]: "..tostring(message))
end

function platform:error(message)
	if message==nil then return end
	return platform:print("["..get_time_stamp(platform:get_tick()).."][ERROR]: "..tostring(message))
end

function platform:get_file(path,current_file)
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

function platform:file_exists(file) return false end
function platform:get_sub_files(file) return {} end
function platform:get_full_path(file) return "" end

function platform:open_file(file_name,mode) return nil end

function platform:require(file)
	local success,lib=pcall(require,platform:get_file(file))
	if success==false then
		platform:info(lib)
	end
	return lib
end

function platform:yield(duration) end
function platform:get_tick() return 0 end
function platform:get_frame_rate() return 0 end

function platform:get_joystick_key_press(joystick_id,...) return false end
function platform:get_key_press(...) return false end
function platform:get_mouse_key_press(...) return false end
function platform:update_pointers() end

function platform:set_filter_mode(min_mode,max_mode,anistropy) end
function platform:set_blend_mode(mode,alpha_mode)  end

function platform:set_cursor_visibility(state) end
function platform:set_cursor_lock(state) end

function platform:get_buffer_resolution(buffer) return {x=0,y=0} end

function platform:get_max_resolution() return {x=0,y=0} end

function platform:load_source(file,file_type,properties) return end
function platform:load_sources(files) return end
function platform:unload_source(file) end
function platform:clear_sources()
	for i,_ in pairs(platform.assets) do
		platform:unload_source(i)
	end
end

function platform:create_buffer(...) end
function platform:set_current_buffer(...) end
function platform:clear_buffer(color,opacity,active_buffers) end

function platform:render_image(source,position,size,rotation,wrap,background_color,source_color,filter_mode,anistropy,buffer) end

function platform:get_text_size(text,font,font_size) return {x=0,y=0} end

function platform:render_text(text,position,wrap,wrapped,color,alignment,font,font_size,buffer) end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio_object={
		source=nil;
	}
	function audio_object:set_source(source) end
	function audio_object:set_state(state) end
	function audio_object:play() end
	function audio_object:pause() end
	function audio_object:resume() end
	function audio_object:stop() end
	function audio_object:set_position(position) end
	function audio_object:set_loop(state) end
	function audio_object:set_pitch(pitch) end
	function audio_object:set_volume(volume) end
	function audio_object:get_source() return end
	function audio_object:get_playing_state() return false end
	function audio_object:get_pause() return false end
	function audio_object:get_position() return 0 end
	function audio_object:get_duration() return 0 end
	function audio_object:get_loop() return false end
	function audio_object:get_volume() return 0 end
	function audio_object:get_pitch() return 0 end
	
	--audio_object:play();audio_object:pause();
	audio_object:set_volume(properties.volume)
	audio_object:set_position(properties.position)
	audio_object:set_pitch(properties.pitch)
	audio_object:set_loop(properties.loop)
	
	return audio_object
end

function platform:set_error_handler(handler) end

function platform:set_screen_mode(mode) end
function platform:set_window(resolution,title,frame_rate) end
function platform:set_window_position(position) end

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
	
	--::::::::::::::::::::[Rendering]::::::::::::::::::::
	
end
--_____________________________________________________________________________

return platform