--[[************************************************************

	Audiolib written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	return function(properties)
		local audio=thread.scheduler.platform:create_audio(properties)
		
		local current_pause_state=audio:get_pause()
		audio.runtime_attachment=thread.runtime.run_state:attach(function(state)
			if state==false then
				current_pause_state=audio:get_pause()
				audio:pause()
			elseif state==true then
				if current_pause_state==true then
					audio:play()
				end
			end
		end)
		
		return audio
	end
end