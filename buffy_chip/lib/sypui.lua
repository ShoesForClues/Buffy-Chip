--[[************************************************************

	Simple Yet Powerful User Interface

	Software written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,2,5};
		_dependencies={
			"class";
			"stdlib";
			"gel";
			"geffects";
			"easing";
			"audiolib";
		};
		elements={};
		enum={
			orientation={
				top={};
				bottom={};
				left={};
				right={};
			};
		};
	}
	
	local button_element=thread.libraries["gel"].elements.default_element:extend() --::::::::::::::::::::[Button Element]::::::::::::::::::::
	function button_element:__tostring() return "button_element" end
	function button_element:new(properties)
		button_element.super.new(self,{
			parent_element=properties.parent_element;
			position=properties.position;
			size=properties.size;
			visible=properties.visible;
			wrapped=properties.wrapped;
		})
		
		self.transition_speed=thread.libraries["stdlib"]:create_property(properties.transition_speed or 0.1)
		self.transition_easing_style=thread.libraries["stdlib"]:create_property(properties.transition_easing_style or thread.libraries["easing"].linear)
		
		--[[
		self.frame=thread.libraries["gel"].elements.slice_element({
			parent_element=self;
			position={
				offset={x=0,y=0};
				scale={x=0.5,y=0.5};
			};
			size={offset={x=0,y=0},scale={x=0,y=0}};
			slice_source=properties.slice_source or thread.platform:load_source("assets/textures/frames/frame_3.png",thread.platform.enum.file_type.image);
			source_resolution=properties.source_resolution or {x=50,y=50};
			slice_center=properties.slice_center or {x1=5,y1=5,x2=45,y2=45};
			slice_color=properties.slice_color or {r=1,g=1,b=1};
			slice_opacity=properties.slice_opacity or 0;
			visible=true;
			wrapped=true;
		})
		--]]
		
		self.frame=thread.libraries["gel"].elements.text_element({
			parent_element=self;
			position={
				offset={x=0,y=0};
				scale={x=0.5,y=0.5};
			};
			size={offset={x=0,y=0},scale={x=0,y=0}};
			source=properties.slice_source or thread.platform:load_source("assets/textures/frames/frame_3.png",thread.platform.enum.file_type.image);
			color=properties.color or {r=1,g=1,b=1};
			opacity=properties.opacity or 0;
			visible=true;
			wrapped=true;
			text=properties.text or "";
			text_color=properties.text_color or {r=1,g=1,b=1};
			text_opacity=properties.text_opacity or 0;
			font=properties.font or thread.platform:load_source("assets/fonts/terminus.ttf",thread.platform.enum.file_type.font);
			font_size=18;
			text_scaled=false;
			text_wrapped=true;
		})
		
		self.pressed:attach_bind(function(state)
			if state==true then
				thread.libraries["geffects"]:tween_size_and_position(
					self.frame,
					{offset={x=0,y=0},scale={x=0.9,y=0.9}},{offset={x=0,y=0},scale={x=0.05,y=0.05}},
					0,self.transition_easing_style.value
				)
			elseif state==false then
				thread.libraries["geffects"]:tween_size_and_position(
					self.frame,
					{offset={x=0,y=0},scale={x=1,y=1}},{offset={x=0,y=0},scale={x=0,y=0}},
					self.transition_speed.value,self.transition_easing_style.value
				)
			end
		end)
		
		thread:create_thread(function(t)
			thread.libraries["geffects"]:tween_size_and_position(
				self.frame,
				{offset={x=0,y=0},scale={x=1,y=1}},{offset={x=0,y=0},scale={x=0,y=0}},
				properties.open_transition_speed or 0.3,
				properties.open_easing_style or thread.libraries["easing"].outQuad
			)
		end)
	end
	
	local progress_bar=thread.libraries["gel"].elements.slice_element:extend() --::::::::::::::::::::[Progress Bar]::::::::::::::::::::
	function progress_bar:__tostring() return "progress_bar" end
	function progress_bar:new(properties)
		properties.position=properties.position or {offset={x=0,y=0},scale={x=0,y=0}}
		properties.size=properties.size or {offset={x=0,y=0},scale={x=0,y=0}}
		progress_bar.super.new(self,{
			parent_element=properties.parent_element;
			position=properties.position;
			size={offset={x=0,y=properties.size.offset.y},scale={x=0,y=properties.size.scale.y}};
			slice_source=properties.slice_source or thread.platform:load_source("assets/textures/frames/frame_3.png",thread.platform.enum.file_type.image);
			source_resolution=properties.source_resolution or {x=50,y=50};
			slice_center=properties.slice_center or {x1=5,y1=5,x2=45,y2=45};
			slice_color=properties.slice_color or {r=1,g=1,b=1};
			slice_opacity=properties.slice_opacity or 0;
			visible=properties.visible;
			wrapped=true;
		})
		
		self.bar=thread.libraries["gel"].elements.default_element({
			parent_element=self;
			source=thread.platform:load_source("assets/textures/blank.png",thread.platform.enum.file_type.image);
			position={offset={x=3,y=3},scale={x=0,y=0}};
			size={offset={x=-6,y=-6},scale={x=0,y=1}};
			color=properties.color or {r=0.9,g=0.9,b=0.9};
			opacity=properties.opacity or 0.3;
			visible=true;
			wrapped=false;
		})
		
		self.bar_orientation=thread.libraries["stdlib"]:create_property(properties.bar_orientation or API.enum.orientation.left)
		self.bar_size_percent=thread.libraries["stdlib"]:create_property(properties.bar_size_percent or 0)
		self.transition_speed=thread.libraries["stdlib"]:create_property(properties.transition_speed or 0.2)
		
		self.bar_orientation:attach_bind(function(orientation)
			if orientation==API.enum.orientation.left then
				self.bar.position:set_value({offset={x=3,y=3},scale={x=0,y=0}})
				self.bar.size:set_value({offset={x=-6,y=-6},scale={x=thread.libraries["stdlib"]:clamp(self.bar_size_percent.value,0,1),y=1}})
			elseif orientation==API.enum.orientation.right then
				self.bar.position:set_value({offset={x=3,y=3},scale={x=1-thread.libraries["stdlib"]:clamp(self.bar_size_percent.value,0,1),y=0}})
				self.bar.size:set_value({offset={x=-6,y=-6},scale={x=thread.libraries["stdlib"]:clamp(self.bar_size_percent.value,0,1),y=1}})
			elseif orientation==API.enum.orientation.top then
				self.bar.position:set_value({offset={x=3,y=3},scale={x=0,y=0}})
				self.bar.size:set_value({offset={x=-6,y=-6},scale={x=1,y=thread.libraries["stdlib"]:clamp(self.bar_size_percent.value,0,1)}})
			elseif orientation==API.enum.orientation.bottom then
				self.bar.position:set_value({offset={x=3,y=3},scale={x=0,y=1-thread.libraries["stdlib"]:clamp(self.bar_size_percent.value,0,1)}})
				self.bar.size:set_value({offset={x=-6,y=-6},scale={x=1,y=thread.libraries["stdlib"]:clamp(self.bar_size_percent.value,0,1)}})
			end
		end)
		
		self.bar_size_percent:attach_bind(function(value)
			if self.bar_orientation.value==API.enum.orientation.left then
				thread.libraries["geffects"]:tween_udim2(
					self.bar.size,{offset={x=-6,y=-6},scale={x=thread.libraries["stdlib"]:clamp(value,0,1),y=1}},
					self.transition_speed.value,thread.libraries["easing"].outQuad,thread.runtime
				)
			elseif self.bar_orientation.value==API.enum.orientation.right then
				thread.libraries["geffects"]:tween_size_and_position(
					self.bar,
					{offset={x=-6,y=-6},scale={x=thread.libraries["stdlib"]:clamp(value,0,1),y=1}},
					{offset={x=3,y=3},scale={x=1-thread.libraries["stdlib"]:clamp(value,0,1),y=0}},
					self.transition_speed.value,thread.libraries["easing"].outQuad,thread.runtime
				)
			elseif self.bar_orientation.value==API.enum.orientation.top then
				thread.libraries["geffects"]:tween_udim2(
					self.bar.size,{offset={x=-6,y=-6},scale={x=1,y=thread.libraries["stdlib"]:clamp(value,0,1)}},
					self.transition_speed.value,thread.libraries["easing"].outQuad,thread.runtime
				)
			elseif self.bar_orientation.value==API.enum.orientation.bottom then
				thread.libraries["geffects"]:tween_size_and_position(
					self.bar,
					{offset={x=-6,y=-6},scale={x=1,y=thread.libraries["stdlib"]:clamp(value,0,1)}},
					{offset={x=3,y=3},scale={x=0,y=1-thread.libraries["stdlib"]:clamp(value,0,1)}},
					self.transition_speed.value,thread.libraries["easing"].outQuad,thread.runtime
				)
			end
		end)
		
		thread:create_thread(function(t)
			self.bar_orientation:invoke(self.bar_orientation.value or API.enum.orientation.left)
				
			if self.bar_orientation.value==API.enum.orientation.left then
				self.position:set_value(properties.position)
				self.size:set_value({offset={x=0,y=properties.size.offset.y},scale={x=0,y=properties.size.scale.y}})
			elseif self.bar_orientation.value==API.enum.orientation.right then
				self.position:set_value({
					offset={
						x=properties.position.offset.x+properties.size.offset.x;
						y=properties.position.offset.y;
					};
					scale={
						x=properties.position.scale.x+properties.size.scale.x;
						y=properties.position.scale.y;
					};
				})
				self.size:set_value({offset={x=0,y=properties.size.offset.y},scale={x=0,y=properties.size.scale.y}})
			elseif self.bar_orientation.value==API.enum.orientation.top then
				self.position:set_value(properties.position)
				self.size:set_value({offset={x=properties.size.offset.x,y=0},scale={x=properties.size.scale.x,y=0}})
			elseif self.bar_orientation.value==API.enum.orientation.bottom then
				self.position:set_value({
					offset={
						x=properties.position.offset.x;
						y=properties.position.offset.y+properties.size.offset.y;
					};
					scale={
						x=properties.position.scale.x;
						y=properties.position.scale.y+properties.size.scale.y;
					};
				})
				self.size:set_value({offset={x=properties.size.offset.x,y=0},scale={x=properties.size.scale.x,y=0}})
			end
			
			thread.libraries["geffects"]:tween_size_and_position(
				self,
				properties.size,properties.position,
				properties.open_transition_speed or 0.3,
				properties.open_easing_style or thread.libraries["easing"].outQuad
			)
		end)
	end
	
	API.elements.progress_bar=progress_bar
	API.elements.button_element=button_element
	
	return API
end