--________________________________Dependencies_________________________________
--local player_gui=game.Players.LocalPlayer:WaitForChild("PlayerGui")
--local starter_gui=game:GetService('StarterGui')
local run_service=game:GetService("RunService")
local user_input_service=game:GetService('UserInputService')
local stdplib=require(script.Parent.Parent:WaitForChild("lib"):WaitForChild("stdplib"))
--_____________________________________________________________________________

local platform={
	_target="roblox_server";
	_version={0,2,2};
	
	start_tick=tick();
	
	enum={
		filter_mode={
			linear="linear";
			nearest="nearest";
		};
		audio_state={
			play={};
			stop={};
			pause={};
		};
		file_type={
			image=0x05;
			font=0x06;
			audio=0x07;
			script=0x08;
			model=0x09;
			local_file=0x0A;
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
		cursor_behavior={
			default=Enum.MouseBehavior.Default;
			lock_center=Enum.MouseBehavior.LockCenter;
		};
	};
	
	assets={}; --Asset bank
	
	text_input=stdplib:create_signal();
	key_state=stdplib:create_signal();
	mouse_key_state=stdplib:create_signal();
	mouse_moved=stdplib:create_signal();
	mouse_position=stdplib:create_property(Vector2.new(0,0));
	pointers=stdplib:create_property({});

	update_stepped=stdplib:create_signal();
	render_stepped=stdplib:create_signal();
	
	current_screen_mode=stdplib:create_property("WINDOW");
	screen_resolution=stdplib:create_property({x=0,y=0});
	
	output_update=stdplib:create_signal();
	
	default={
		font={};
	};
	
	current_file=script.Parent.Parent;
}

function platform:get_running_platform()                                                           --Get the platform specs
	return {operating_system="Unknown";bits=32;}
end

function platform:execute_command(code) if code==nil then return end                               --Execute OS specific commands
	--[[	
	local handle=io.popen(code)
	local output=handle:read("*a")
	handle:close()
	return output
	--]]
end

function platform:exit() end                                                                       --End the program

function platform:print(text) print(text) platform.output_update:invoke(text) end                  --Output text to console
function platform:info(message) if message==nil then return end                                    --Output info to console
	platform:print("[Server]["..stdplib:get_time_stamp(platform:get_tick()).."]: "..tostring(message))
end

function platform:get_file(path,current_file)                                                      --Retrieve file via path
	current_file=current_file or platform.current_file	
	if path==nil then return end
	path=path.." "
	local file_name=""
	local path_len=string.len(path)
	local step=0
	for a=1,path_len do
		local char=string.sub(path,a,a)
		if char~="/" and char~="\\" and a<path_len then
			file_name=file_name..char
		else
			if char=="\\" and current_file~=nil then
				current_file=current_file.Parent
			end
			if step<=0 and file_name=="root" then
				current_file=game
			elseif current_file~=nil then
				current_file=current_file:FindFirstChild(file_name)
			end
			file_name=""
			step=step+1
		end
	end
	return current_file
end

function platform:file_exists(file) return platform:get_file(file)~=nil end                        --Check if file exists

function platform:require(file)                                                                    --Get a value from a lua file
	return require(platform:get_file(file))
end

function platform:yield(duration) return wait(duration) end                                        --Yield the entire thread
function platform:get_tick() return tick()-platform.start_tick end                                 --Get the current clock tick
function platform:get_fps() return workspace:GetRealPhysicsFPS() end                               --Get the current FPS

function platform:get_key_press(key) return user_input_service:IsKeyDown(key) end                          --Check if keyboard button is pressed
function platform:get_mouse_key_press(key)                                                         --Check if mouse button is pressed
	local state=false
	if key==1 then
		state=user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	elseif key==2 then
		state=user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	elseif key==3 then
		state=user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
	end
end
function platform:update_pointers()                                                                --Update pointers
	local pointers={}
	--[[
	for _,id in pairs(love.touch.getTouches()) do
		local touch_x,touch_y=love.touch.getPosition(id)
		table.insert(pointers,#pointers+1,{id=id,position={x=touch_x,y=touch_y}})
	end
	--]]
	platform.pointers:set_value(pointers)
end

function platform:set_cursor_visibility(state)                                                     --Set cursor visibility
	user_input_service.MouseIconEnabled=state
end
function platform:set_cursor_behavior(state)                                                       --Set cursor behavior
	user_input_service.MouseBehavior=state
end

function platform:load_source(file,file_type,properties)                                      --Load asset in memory for future reference
	if file==nil or file_type==nil then return end
	properties=properties or {}
	local source
	local success=true
	if file_type==platform.enum.file_type.model then
		success,source=pcall(game:GetService("InsertService").LoadAsset,file)
	elseif file_type==platform.enum.file_type.local_file then
		platform.assets[file]=platform:get_file(file)
		if platform.assets[file]~=nil then
			source=platform.assets[file]:Clone()
		end
	end
	if success==false or source==nil then
		platform:info("Failed to load: "..file)
	end
	return source
end

function platform:create_audio(properties)                                                         --Create an audio source
	local audio=Instance.new("Sound")
	audio.Name=properties.Name or "audio"
	audio.EmitterSize=properties.emitter_size or 10
	audio.Looped=properties.loop or false
	audio.MaxDistance=properties.max_distance or 1000
	audio.PlaybackSpeed=properties.playback_speed or 1
	audio.RollOffMode=properties.roll_off_mode or Enum.RollOffMode.Inverse
	audio.SoundGroup=properties.sound_group or nil
	audio.SoundId=properties.source or ""
	audio.TimePosition=properties.time_position or 0
	audio.Volume=properties.volume or 1
	audio.Archivable=true
	audio.PlayOnRemove=false
	audio.Parent=properties.parent or workspace.CurrentCamera
	
	local audio_object={
		source=audio
	}
	function audio_object:set_source(source)
		audio_object.source.SoundId=source
	end
	function audio_object:set_parent(parent)
		audio_object.parent=parent
	end
	function audio_object:set_state(state)
		if state==platform.enum.audio_state.play then
			audio_object.source:Play()
		elseif state==platform.enum.audio_state.stop then
			audio_object.source:Stop()
		elseif state==platform.enum.audio_state.pause then
			audio_object.source:Pause()
		end
	end
	function audio_object:play()
		audio_object.source:Play()
	end
	function audio_object:pause()
		audio_object.source:Pause()
	end
	function audio_object:resume()
		audio_object.source:Resume()
	end
	function audio_object:stop()
		audio_object.source:Stop()
	end
	function audio_object:set_position(position) position=position or 0
		audio_object.source.TimePosition=position
	end
	function audio_object:set_loop(state) state=state or false
		audio_object.source.Looped=state
	end
	function audio_object:set_pitch(pitch) pitch=pitch or 1
		audio_object.source.PlaybackSpeed=pitch
	end
	function audio_object:set_volume(volume) volume=volume or 1
		audio_object.source.Volume=volume
	end
	function audio_object:get_source() return audio_object.source end
	function audio_object:get_playing_state()
		return audio_object.source.IsPlaying
	end
	function audio_object:get_pause()
		return audio_object.source.IsPaused
	end
	function audio_object:get_position()
		return audio_object.source.TimePosition
	end
	function audio_object:get_duration()
		return audio_object.source.TimeLength
	end
	function audio_object:get_loop()
		return audio_object.source.Looped
	end
	function audio_object:get_volume()
		return audio_object.source.Volume
	end
	function audio_object:get_pitch()
		return audio_object.source.PlaybackSpeed
	end
	
	return audio_object
end

--____________________________________Setup____________________________________
function platform:initialize(properties)
	properties=properties or {}
	
	--[[
	game.ReplicatedFirst:RemoveDefaultLoadingScreen()
	user_input_service.ModalEnabled=true
	player_gui:SetTopbarTransparency(0)
	starter_gui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false)
	starter_gui:SetCore("TopbarEnabled",false)
	
	platform:set_cursor_visibility(properties.cursor_visible)
	platform:set_cursor_behavior(properties.cursor_behavior or platform.enum.cursor_behavior.default)
	--]]
	
	--::::::::::::::::::::[Callbacks]::::::::::::::::::::
	--[[
	user_input_service.InputBegan:connect(function(input)
		if input.UserInputType==Enum.UserInputType.Keyboard then
			 platform.key_state:invoke({key=input.KeyCode,state=true})
		elseif input.UserInputType==Enum.UserInputType.MouseButton1 then
			platform.mouse_key_state:invoke({key=1,state=true})
		elseif input.UserInputType==Enum.UserInputType.MouseButton2 then
			platform.mouse_key_state:invoke({key=2,state=true})
		elseif input.UserInputType==Enum.UserInputType.MouseButton3 then
			platform.mouse_key_state:invoke({key=3,state=true})
		end
	end)
	user_input_service.InputEnded:connect(function(input)
		if input.UserInputType==Enum.UserInputType.Keyboard then
			 platform.key_state:invoke({key=input.KeyCode,state=false})
		elseif input.UserInputType==Enum.UserInputType.MouseButton1 then
			platform.mouse_key_state:invoke({key=1,state=false})
		elseif input.UserInputType==Enum.UserInputType.MouseButton2 then
			platform.mouse_key_state:invoke({key=2,state=false})
		elseif input.UserInputType==Enum.UserInputType.MouseButton3 then
			platform.mouse_key_state:invoke({key=3,state=false})
		end
	end)
	user_input_service.InputChanged:connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement then
			platform.mouse_position:set_value(input.Position)
			platform.mouse_moved:invoke(Vector2.new(input.Delta.x,input.Delta.y))
		end
	end)
	--]]
	run_service.Heartbeat:Connect(function(...) platform.update_stepped:invoke(...) end)
	
	--::::::::::::::::::::[Rendering]::::::::::::::::::::
	if run_service:IsClient() then
		run_service.RenderStepped:Connect(function(...) platform.render_stepped:invoke(...) end)
	elseif run_service:IsServer() then
		run_service.Stepped:Connect(function(...) platform.render_stepped:invoke(...) end)
	end
end
--_____________________________________________________________________________

return platform