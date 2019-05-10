--[[************************************************************

	Gel Effects written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,0,9};
		dependencies={
			"stdlib";
		};
	}
	
	function API:calculate_tween(value,goal,percent,easing)
		return easing(percent,value,goal-value,1)
	end
	
	function API:tween_number(value,goal,duration,easing) --This one utilizes frame skipping
		if value==nil or goal==nil or duration==nil or easing==nil then return end
		if value.current_tween_thread~=nil then
			value.current_tween_thread:delete()
			value.current_tween_thread=nil
		end
		local start=value.value
		local change=goal-start
		local start_tick=thread.scheduler.platform:get_tick()
		local finished=false
		local tween_thread=thread:create_thread(function(thread)
			while thread.scheduler.platform:get_tick()<start_tick+duration do
				value:set_value(easing(thread.scheduler.platform:get_tick()-start_tick,start,change,duration))
				thread.runtime:wait(0.03)
			end
			value:set_value(goal)
			finished=true
		end)
		value.current_tween_thread=tween_thread
		repeat thread.runtime:wait() until finished==true or value.current_tween_thread~=tween_thread
	end
	
	function API:tween_vector_2(value,goal,duration,easing)
		if value==nil or goal==nil or duration==nil or easing==nil then return end
		if value.current_tween_thread~=nil then
			value.current_tween_thread:delete()
			value.current_tween_thread=nil
		end
		local start=value.value
		local change_x=goal.x-start.x
		local change_y=goal.y-start.y
		local start_tick=thread.scheduler.platform:get_tick()
		local finished=false
		local tween_thread=thread:create_thread(function(thread)
			while thread.scheduler.platform:get_tick()<start_tick+duration do
				value:set_value({
					x=easing(thread.scheduler.platform:get_tick()-start_tick,start.x,change_x,duration);
					y=easing(thread.scheduler.platform:get_tick()-start_tick,start.y,change_y,duration);
				})
				thread.runtime:wait(0.03)
			end
			value:set_value(goal)
			finished=true
		end)
		value.current_tween_thread=tween_thread
		repeat thread.runtime:wait() until finished==true or value.current_tween_thread~=tween_thread
	end
	
	--[[
	function API:tween_number(value,goal,duration,easing,runtime) runtime=runtime or thread.runtime
		if value==nil or goal==nil or duration==nil or easing==nil then return end
		duration=duration*30
		local fps=1/30
		local start=value.value
		local change=goal-start
		for i=0,duration do
			value:set_value(easing(i,start,change,duration))
			runtime:wait(fps)
		end
		value:set_value(goal)
	end
	--]]
	
	function API:tween_color(value,goal,duration,easing,runtime)
		runtime=runtime or thread.runtime
		if value==nil or goal==nil or duration==nil or easing==nil then return end
		duration=duration*30
		local fps=1/30
		local start=thread.libraries["stdlib"]:copy(value.value,true)
		local change_r=goal.r-start.r
		local change_g=goal.g-start.g
		local change_b=goal.b-start.b
		local change_a=goal.a-start.a
		for i=0,duration do
			value:set_value({
				r=easing(i,start.r,change_r,duration);
				g=easing(i,start.g,change_g,duration);
				b=easing(i,start.b,change_b,duration);
				a=easing(i,start.a,change_a,duration);
			})
			runtime:wait(fps)
		end
		value:set_value(goal)
	end
	
	function API:tween_udim2(value,goal,duration,easing)
		if value==nil or goal==nil or duration==nil or easing==nil then return end
		if value.current_tween_thread~=nil then
			value.current_tween_thread:delete()
			value.current_tween_thread=nil
		end
		local start=thread.libraries["stdlib"]:copy(value.value,true)
		local change_offset_x=goal.offset.x-start.offset.x
		local change_offset_y=goal.offset.y-start.offset.y
		local change_scale_x=goal.scale.x-start.scale.x
		local change_scale_y=goal.scale.y-start.scale.y
		local start_tick=thread.scheduler.platform:get_tick()
		local finished=false
		local tween_thread=thread:create_thread(function(thread)
			while thread.scheduler.platform:get_tick()<start_tick+duration do
				value:set_value({
					offset={
						x=easing(thread.scheduler.platform:get_tick()-start_tick,start.offset.x,change_offset_x,duration);
						y=easing(thread.scheduler.platform:get_tick()-start_tick,start.offset.y,change_offset_y,duration);
					};
					scale={
						x=easing(thread.scheduler.platform:get_tick()-start_tick,start.scale.x,change_scale_x,duration);
						y=easing(thread.scheduler.platform:get_tick()-start_tick,start.scale.y,change_scale_y,duration);
					};
				})
				thread.runtime:wait(0.03)
			end
			value:set_value(goal)
			finished=true
		end)
		value.current_tween_thread=tween_thread
		repeat thread.runtime:wait() until finished==true or value.current_tween_thread~=tween_thread
	end
	
	function API:tween_size_and_position(element,goal_size,goal_position,duration,easing)
		if element==nil or goal_size==nil or goal_position==nil or duration==nil or easing==nil then return end
		local finished_position,finished_size=false,false
		thread:create_thread(function(t)
			API:tween_udim2(element.position,goal_position,duration,easing)
			finished_position=true
		end)
		thread:create_thread(function(t)
			API:tween_udim2(element.size,goal_size,duration,easing)
			finished_size=true
		end)
		repeat thread.runtime:wait() until finished_position==true and finished_size==true
	end
	
	function API:apply_text_effect(text_element,effect)
		if text_element==nil or effect==nil then return end
		for _,char_element in pairs(text_element.char_elements.value) do
			effect(char_element)
		end
	end
	
	return API
end