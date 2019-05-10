--[[************************************************************

	Form written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,0,3};
		_dependencies={
			"stdlib";
			"gel";
			"easing";
			"gel_effects";
		};
		elements={};
		default={
			source=thread.platform:load_source("assets/textures/blank.png");
			frame_source=thread.platform:load_source("assets/textures/frames/frame_1.png");
		};
	}
	
	function API:post_import_setup()
		local default_element=thread.libraries["gel"].elements.slice_element:extend()
		function default_element:new(properties)
			properties.source=properties.source or API.default.source
			properties.slice_source=properties.slice_source or API.default.frame_source;
			properties.slice_center=properties.slice_center or {x1=2,y1=2,x2=98,y2=98};
			properties.source_resolution=properties.source_resolution or {x=100,y=100};
			default_element.super.new(self,properties)
		end
		
		local text_element=default_element:extend() --::::::::::::::::::::[Text Element]::::::::::::::::::::
		function text_element:new(properties)
			text_element.super.new(self,properties)
			
			self.text=thread.libraries["stdlib"]:create_property(properties.text or "")
			self.font=thread.libraries["stdlib"]:create_property(properties.font)
			self.font_size=thread.libraries["stdlib"]:create_property(properties.font_size or 8)
			self.text_opacity=thread.libraries["stdlib"]:create_property(properties.text_opacity or 0)
			self.text_color=thread.libraries["stdlib"]:create_property(properties.text_color or {r=1,g=1,b=1})
			self.text_scaled=thread.libraries["stdlib"]:create_property(properties.text_scaled or false)
			self.text_alignment=thread.libraries["stdlib"]:create_property(properties.text_alignment or {x=API.enum.text_alignment.x.center,y=API.enum.text_alignment.y.center})
			self.multi_line=thread.libraries["stdlib"]:create_property(properties.multi_line or false)
		end
		
		function text_element:render()
			text_element.super.render(self)
			local font_size=self.font_size.value
			if self.text_scaled.value==true then
				font_size=math.floor(self.slice_box.absolute_size.value.y*5/6)
			end
			thread.platform:render_text(
				self.text.value,
				self.slice_box.absolute_position.value,
				self.slice_box.wrap.value,
				self.text_color.value,
				self.text_opacity.value,
				self.text_alignment.value,
				self.font.value,
				font_size
			)
		end
		
		local text_box_element=text_element:extend() --::::::::::::::::::::[Text Box Element]::::::::::::::::::::
		function text_box_element:new(properties)
			text_box_element.super.new(self,properties)
			
			self.text_input_bind=thread.platform.text_input:attach_bind(function(_,text)
				if self:get_focused_element()==self then
					self.text:set_value(self.text.value..tostring(text))
				end
			end)
		end
		
		local window_element=thread.libraries["gel"].elements.default_element:extend() --::::::::::::::::::::[Window Element]::::::::::::::::::::
		function window_element:new(properties)
			window_element.super.new(self,{
				parent_element=properties.parent_element;
				size=properties.size;
				visible=true;
				wrapped=false;
				draggable=true;
				delete_on_thread_kill=true;
			})
			self.size:set_value({offset={x=self.size.value.offset.x,y=20},scale={x=self.size.value.scale.x,y=0}})
			
			self.window_frame=thread.libraries["gel"].elements.slice_element({
				parent_element=self;
				size=properties.size;
				slice_source=properties.window_frame_source or API.default.window_frame_source;
				source_resolution=properties.window_frame_resolution or API.default.window_frame_resolution;
				slice_center=properties.window_frame_slice_center or API.default.window_frame_slice_center;
				slice_opacity=1;
				slice_color=properties.window_frame_color or API.default.window_frame_color;
				wrapped=true;
				visible=true;
			})
			
			self.window_box=thread.libraries["gel"].elements.default_element({
				parent_element=self.window_frame;
				source=properties.window_box_source or API.default.window_box_source;
				position={offset={x=self.window_frame.slice_center.value.x1,y=self.window_frame.slice_center.value.y1},scale={x=0,y=0}};
				size={
					offset={
						x=-(self.window_frame.slice_center.value.x1+(self.window_frame.source_resolution.value.x-self.window_frame.slice_center.value.x2)),
						y=-(self.window_frame.slice_center.value.y1+(self.window_frame.source_resolution.value.y-self.window_frame.slice_center.value.y2))
					};
					scale={x=1,y=1}
				};
				color=properties.window_box_color or API.default.window_box_color;
				opacity=1;
				wrapped=true;
				visible=true;
			})
			
			self.title_bar=text_element({
				parent_element=self.window_frame;
				source=properties.title_bar_source or API.default.title_bar_source;
				position={offset={x=5,y=5},scale={x=0,y=0}};
				size={offset={x=0,y=15},scale={x=0,y=0}};
				color=properties.title_bar_color or API.default.title_bar_color;
				opacity=properties.title_bar_opacity or API.default.title_bar_opacity;
				text=properties.title or "";
				text_color=properties.title_text_color or API.default.title_text_color;
				text_opacity=1;
				text_scaled=false;
				font_size=10;
				font=properties.title_font or API.default.title_font;
				text_alignment={
					x=thread.libraries["gel"].enum.text_alignment.x.left,
					y=thread.libraries["gel"].enum.text_alignment.y.center
				};
				wrapped=true;
				visible=true;
			})
			
			self.work_box=thread.libraries["gel"].elements.default_element({
				parent_element=self.window_box;
				source=properties.work_box_source or API.default.work_box_source;
				position={offset={x=3,y=23},scale={x=0,y=0}};
				size={offset={x=-6,y=0},scale={x=1,y=0}};
				color=properties.work_box_color or API.default.work_box_color;
				opacity=properties.work_box_opacity or API.default.work_box_opacity;
				wrapped=true;
				visible=true;
			})
			
			if properties.visible==true then self:open() end
		end
		
		function window_element:open()
			local progress=0
			self.visible:set_value(true)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_number(
					self.window_frame.slice_opacity,API.default.window_frame_opacity,
					0.25,thread.libraries["easing"].linear,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_number(
					self.window_box.opacity,API.default.window_box_opacity,
					0.25,thread.libraries["easing"].linear,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_udim2(
					self.title_bar.size,{offset={x=-10,y=15},scale={x=1,y=0}},
					0.25,thread.libraries["easing"].outQuad,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_number(
					self.title_bar.text_opacity,API.default.title_text_opacity,
					0.25,thread.libraries["easing"].outQuad,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_udim2(
					self.work_box.size,{offset={x=-6,y=-26},scale={x=1,y=1}},
					0.25,thread.libraries["easing"].outQuad,t.runtime
				)
				progress=progress+1
			end)
			repeat thread.runtime:wait() until progress>=5
		end
		
		function window_element:close()
			local progress=0
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_number(
					self.window_frame.slice_opacity,1,
					0.25,thread.libraries["easing"].linear,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_number(
					self.window_box.opacity,1,
					0.25,thread.libraries["easing"].linear,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_udim2(
					self.title_bar.size,{offset={x=0,y=15},scale={x=0,y=0}},
					0.25,thread.libraries["easing"].outQuad,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_number(
					self.title_bar.text_opacity,1,
					0.25,thread.libraries["easing"].outQuad,t.runtime
				)
				progress=progress+1
			end)
			thread:create_thread(function(t)
				thread.libraries["gel_effects"]:tween_udim2(
					self.work_box.size,{offset={x=-6,y=0},scale={x=1,y=0}},
					0.25,thread.libraries["easing"].outQuad,t.runtime
				)
				progress=progress+1
			end)
			repeat thread.runtime:wait() until progress>=5
			self.visible:set_value(false)
		end
		
		API.elements.default_element=default_element
		API.elements.text_element=text_element
		API.elements.text_box_element=text_box_element
		API.elements.window_element=window_element
	end
	return API
end