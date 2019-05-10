--[[************************************************************

	 ______  __  __   ______   __   ______   __   __    
	/\  ___\/\ \/\ \ /\  ___\ /\ \ /\  __ \ /\ "-.\ \   
	\ \  __\\ \ \_\ \\ \___  \\ \ \\ \ \_\ \\ \ \-.  \  
	 \ \_\   \ \_____\\/\_____\\ \_\\ \_____\\ \_\\"\_\ 
	  \/_/    \/_____/ \/_____/ \/_/ \/_____/ \/_/ \/_/ 

	Fusion framework created by Jason Lee Copyright (c) 2019
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

local fusion={
	_version={0,7,2};
	_config={
		show_splash_screen=false;
		core_folder="core";
	};
	_dependencies={
		"eztask";
		"stdplib";
	};
	libraries={};
}

function fusion:import(library,library_name)
	if library_name==nil then return fusion:output("Library name is required") end
	fusion.libraries[library_name]=library
	if type(fusion.libraries[library_name])=="table" then
		fusion.libraries[library_name].platform=fusion.platform
	end
	if fusion.libraries[library_name]~=nil then
		fusion.platform:info("Loaded: "..library_name)
	else
		fusion.platform:warn("Failed to Loaded: "..library_name)
	end
	return fusion.libraries[library_name]
end

function fusion:setup(platform)
	fusion.platform=platform or {}
	
	fusion.platform:info("Fusion Framework created by Jason Lee")
	fusion.platform:info("Version: "..fusion._version[1].."."..fusion._version[2].."."..fusion._version[3])
	
	for _,library_name in pairs(fusion._dependencies) do
		fusion:import(fusion.platform:require(fusion._config.core_folder.."/dep/"..library_name),library_name)
	end
	
	local wrapper=fusion.platform:require(fusion._config.core_folder.."/wrapper")
	
	fusion.platform=fusion.libraries["stdplib"]:merge_tables_deep(fusion.platform,wrapper)
	
	for i=1,#wrapper._version do
		if fusion.platform._version[i]<wrapper._version[i] then
			fusion.platform:warn("Platform API version is outdated!")
			break
		end
	end
	
	fusion.libraries["eztask"].platform=fusion.platform
	
	fusion.scheduler=fusion.libraries["eztask"]:create_scheduler({
		thread_initialization=function(thread)
			
		end;
		scheduler_initialization=function(scheduler)
			scheduler.platform=fusion.platform
		end;
	})
	
	fusion.platform.update_stepped:attach(function()
		fusion.platform:error(fusion.scheduler:cycle(fusion.platform:get_tick()))
	end)
end

return fusion