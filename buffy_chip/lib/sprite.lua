--[[************************************************************

	Sprite written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,0,6};
		dependencies={
			"stdlib";
			"gel";
		};
		elements={};
	}
	
	function API:get_current_frame_and_sheet(index,total_frames,total_sheets,sheet_size)
		return thread.libraries["stdlib"]:clamp(index%sheet_size,1,sheet_size),
		thread.libraries["stdlib"]:clamp(math.floor(index/total_frames*total_sheets)+1,1,total_sheets)
	end
	
	function API:post_import_setup()
		local sprite_element=thread.libraries["gel"].elements.default_element:extend() --::::::::::::::::::::[Sprite Element]::::::::::::::::::::
		function sprite_element:new(properties)
			sprite_element.super.new(self,properties)
			self.current_frame=thread.libraries["stdlib"]:create_property(properties.current_frame or 1)
			self.duration=thread.libraries["stdlib"]:create_property(properties.duration or 0)
			self.playing=thread.libraries["stdlib"]:create_property(properties.playing or false)
			self.loop=thread.libraries["stdlib"]:create_property(properties.loop)
			self.sprite_data=thread.libraries["stdlib"]:create_property(properties.sprite_data or {})
			self.start_tick=thread.platform:get_tick();
			self.compensated_tick=0;
			self.total_frames={estimated_count=0,true_count=0};
			
			self.sprite_parent=thread.libraries["gel"].elements.default_element({
				parent_element=self;
				wrapped=true;
				size={offset={x=0,y=0},scale={x=1,y=1}};
				visible=true;
			})
			self.sprite_sheet=thread.libraries["gel"].elements.default_element({
				parent_element=self.sprite_parent;
				source=self.sprite_data.value.source;
				wrapped=false;
				size={offset={x=0,y=0},scale=self.sprite_data.value.sheet_size};
				visible=true;
				opacity=properties.sprite_sheet_opacity;
				color=properties.sprite_sheet_color;
				filter_mode=properties.sprite_filter_mode;
				anistropy=properties.sprite_anistropy;
			})
			
			self.sprite_data:attach_bind(function() self:calculate_total_frames() end)
			self.playing:attach_bind(function(...) self.start_tick=thread.platform:get_tick() end)
			--self.current_sheet:attach_bind(function() self:update_frame() end)
			self.current_frame:attach_bind(function() self:update_frame() end)
			
			self.thread=thread:create_thread(function(thread)
				while thread.runtime:wait(0.03) do
					if self.playing.value==true then self:step_frame() end
				end
			end)
			
			self:calculate_total_frames()
			self:update_frame()
		end
		
		function sprite_element:calculate_total_frames() if #self.sprite_data.value<=0 then return end
			self.total_frames.estimate_count=#self.sprite_data.value*self.sprite_data.value[1].total_frames
			self.total_frames.true_count=0
			for _,sheet in pairs(self.sprite_data.value) do
				self.total_frames.true_count=self.total_frames.true_count+sheet.total_frames
			end
		end
		
		function sprite_element:compensate_runtime(state) --don't need dis yet
			if state==true then
				
			elseif state==false then
				
			end
		end
		
		function sprite_element:step_frame() if #self.sprite_data.value<=0 then return end
			--self.current_frame.value=math.ceil((thread.platform:get_tick()-self.start_tick)*self.frame_rate.value)
			self.current_frame.value=math.ceil((thread.platform:get_tick()-self.start_tick)*(self.total_frames.true_count/self.duration.value))
			if self.current_frame.value>=self.total_frames.true_count then
				if self.loop.value==true then
					self.start_tick=thread.platform:get_tick()
				else
					self.playing:set_value(false)
				end
			end
			self:update_frame()
		end
		
		function sprite_element:update_frame() if #self.sprite_data.value<=0 then return end
			local current_frame,current_sheet=API:get_current_frame_and_sheet(
				self.current_frame.value,
				self.total_frames.estimate_count,
				#self.sprite_data.value,
				self.sprite_data.value[1].total_frames
			)
			self.sprite_sheet.source:set_value(self.sprite_data.value[current_sheet].source)
			self.sprite_sheet.size.value.scale=self.sprite_data.value[current_sheet].sheet_size
			self.sprite_sheet.position.value.scale={
				x=-(math.floor((current_frame-1)%self.sprite_data.value[current_sheet].sheet_size.x)),
				y=-(math.floor((current_frame-1)/self.sprite_data.value[current_sheet].sheet_size.x))
			}
		end
		
		function sprite_element:delete() sprite_element.super.delete(self) self.thread:delete() end
		
		API.elements.sprite_element=sprite_element
	end
	
	return API
end