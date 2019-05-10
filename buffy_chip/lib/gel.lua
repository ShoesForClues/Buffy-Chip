--[[************************************************************

	GEL written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

local sin,cos,tan=math.sin,math.cos,math.tan
local deg,rad=math.deg,math.rad
local ceil,floor=math.ceil,math.floor

function rotate_point(point,origin,angle)
	local s,c=sin(rad(angle)),cos(rad(angle))
	point.x,point.y=point.x-origin.x,point.y-origin.y
	return {x=(point.x*c-point.y*s)+origin.x,y=(point.x*s+point.y*c)+origin.y}
end

return function(thread)
	local API={
		_version={0,3,2};
		_dependencies={
			"stdlib";
			"eztask";
			"class";
		};
		enum={
			text_alignment={
				x={
					center="center";
					left="left";
					right="right";
				};
				y={
					center="center";
					top="top";
					bottom="bottom";
				};
			};
			slice_type={
				nine={};
			};
			axis={
				x={};
				y={};
			};
		};
		elements={};
		constraint={};
	}

	function API:calculate_char_offset(font,text) if font==nil or text==nil then return {x=0,y=0} end
		local index_position={x=0,y=0}
		for i,char in pairs(font.structure.char_order) do
			if char==text then
				index_position={
					x=-floor((i-1)%font.structure.map_size.x),
					y=-floor((i-1)/font.structure.map_size.y)
				}
				break
			end
		end
		return index_position
	end
	
	function API:is_in_bounds(position,wrap)
		if position==nil or wrap==nil then return false end
		return position.x>=wrap.x1 and position.x<=wrap.x2 and position.y>=wrap.y1 and position.y<=wrap.y2
	end

	function API:constrain_wrap(current,limit)
		current.x1=thread.libraries["stdlib"]:clamp(current.x1,limit.x1,limit.x2)
		current.y1=thread.libraries["stdlib"]:clamp(current.y1,limit.y1,limit.y2)
		current.x2=thread.libraries["stdlib"]:clamp(current.x2,limit.x1,limit.x2)
		current.y2=thread.libraries["stdlib"]:clamp(current.y2,limit.y1,limit.y2)
		return current
	end
	
	function API.constraint:apply_size_ratio(element,ratio,axis) if element==nil then return end
		local constraint={
			element=thread.libraries["eztask"]:create_property(element);
			ratio=thread.libraries["eztask"]:create_property(ratio or 1);
			axis=thread.libraries["eztask"]:create_property(axis or API.enum.axis.y);
			bindings={};
		}
		function constraint:update()
			local absolute_size=constraint.element.value.absolute_size.value
			if constraint.axis.value==API.enum.axis.x then
				constraint.element.value.size.value={
					offset={
						x=constraint.element.value.size.value.offset.x;
						y=absolute_size.x*constraint.ratio.value;
					};
					scale=constraint.element.value.size.value.scale;
				}
			elseif constraint.axis.value==API.enum.axis.y then
				constraint.element.value.size.value={
					offset={
						x=absolute_size.y*constraint.ratio.value;
						y=constraint.element.value.size.value.offset.y;
					};
					scale=constraint.element.value.size.value.scale;
				}
			end
			constraint.element.value:get_absolute_size()
		end
		table.insert(constraint.bindings,#constraint.bindings+1,element.pre_rendered:attach(function()
			constraint:update()
		end))
		constraint.element.value:render()
		return constraint
	end
	
	function API.constraint:apply_center_position(element,position) if element==nil or position==nil then return end
		local constraint={
			element=thread.libraries["eztask"]:create_property(element);
			position=thread.libraries["eztask"]:create_property(position);
			bindings={};
		}
		function constraint:update()
			local absolute_size=constraint.element.value.absolute_size.value
			constraint.element.value.position.value={
				offset={
					x=constraint.position.value.offset.x-(absolute_size.x/2);
					y=constraint.position.value.offset.y-(absolute_size.y/2)
				};
				scale=constraint.position.value.scale;
			}
			constraint.element.value:get_absolute_position()
		end
		table.insert(constraint.bindings,#constraint.bindings+1,element.pre_rendered:attach(function()
			constraint:update()
		end))
		constraint.element.value:render()
		return constraint
	end

	local default_element=thread.libraries["class"]:extend() --::::::::::::::::::::[Default Element]::::::::::::::::::::
	function default_element:__tostring() return "default_element" end
	function default_element:new(properties)
		self.source=thread.libraries["eztask"]:create_property(properties.source)
		self.parent_element=thread.libraries["eztask"]:create_property()
		self.buffer=thread.libraries["eztask"]:create_property(properties.buffer)
		self.child_elements=thread.libraries["eztask"]:create_property({})
		self.z_index=thread.libraries["eztask"]:create_property(properties.z_index or 1)
		self.background_color=thread.libraries["eztask"]:create_property(properties.background_color or {r=1,g=1,b=1,a=0})
		self.source_color=thread.libraries["eztask"]:create_property(properties.source_color or {r=1,g=1,b=1,a=0})
		self.wrapped=thread.libraries["eztask"]:create_property(properties.wrapped or false)
		self.rotation=thread.libraries["eztask"]:create_property(properties.rotation or 0)
		self.position=thread.libraries["eztask"]:create_property(properties.position or {offset={x=0,y=0};scale={x=0,y=0}})
		self.size=thread.libraries["eztask"]:create_property(properties.size or {offset={x=0,y=0};scale={x=0,y=0}})
		self.flipped=thread.libraries["eztask"]:create_property(properties.flipped or false)
		self.visible=thread.libraries["eztask"]:create_property(properties.visible or false)
		self.focused=thread.libraries["eztask"]:create_property(properties.focused or false)
		self.pressed=thread.libraries["eztask"]:create_property(properties.pressed or false)
		self.filter_mode=thread.libraries["eztask"]:create_property(properties.filter_mode or thread.scheduler.platform.enum.filter_mode.nearest)
		self.anistropy=thread.libraries["eztask"]:create_property(properties.anistropy or 0)
		self.selected=thread.libraries["eztask"]:create_property(false)
		self.hovering=thread.libraries["eztask"]:create_property(false)
		self.draggable=thread.libraries["eztask"]:create_property(properties.draggable or false)
		self.global_color=thread.libraries["eztask"]:create_property(properties.global_color or {r=0,g=0,b=0,a=0})
		self.delete_on_thread_kill=thread.libraries["eztask"]:create_property(properties.delete_on_thread_kill or false)

		self.current_buffer=thread.libraries["eztask"]:create_property(self.buffer.value)
		self.absolute_rotation=thread.libraries["eztask"]:create_property(0)
		self.absolute_position=thread.libraries["eztask"]:create_property({x=0,y=0})
		self.absolute_size=thread.libraries["eztask"]:create_property({x=0,y=0})
		self.wrap=thread.libraries["eztask"]:create_property({x1=0,y1=0,x2=0,y2=0})

		self.pre_rendered=thread.libraries["eztask"]:create_signal()
		
		self.binds={}

		self.binds[#self.binds+1]=self.focused:attach(function(current_element)
			if self.parent_element.value~=nil then
				for i,element in pairs(self.parent_element.value.child_elements.value) do
					if element~=self then
						element.focused.value=current_element
					end
				end
				self.parent_element.value.focused:set_value(current_element)
			end
		end)
		
		self.binds[#self.binds+1]=self.parent_element:attach(function(element,old_element)
			if element~=nil and element~=self then
				local already_added=false
				for _,element in pairs(element.child_elements.value) do
					if element==self then
						already_added=true
						break
					end
				end
				if already_added==false then
					element.child_elements:add_value(self)
				end
			end
		end)
		
		self.binds[#self.binds+1]=thread.killed:attach(function()
			if self.delete_on_thread_kill.value==true then
				self:delete()
			end
		end)
		
		self.binds[#self.binds+1]=self.selected:attach(function(state)		
			if state==true then
				self.focused:set_value(self)
				if self.draggable.value==true then
					local offset={
						x=thread.scheduler.platform.cursor_position.value.x-self.position.value.offset.x;
						y=thread.scheduler.platform.cursor_position.value.y-self.position.value.offset.y;
					}
					while self.selected.value==true and self.draggable.value==true do
						self.position:set_value({
							offset={
								x=thread.scheduler.platform.cursor_position.value.x-offset.x;
								y=thread.scheduler.platform.cursor_position.value.y-offset.y;
							};
							scale=self.position.value.scale;
						})
						thread.runtime:wait()
					end
				end
			end
		end)
		
		self.binds[#self.binds+1]=thread.scheduler.platform.mouse_key_state:attach(function(input)
			if input.key==1 and input.state==true and API:is_in_bounds(thread.scheduler.platform.mouse_position.value,self.wrap.value) then
				self.selected:set_value(true)
			else
				self.selected:set_value(false)
			end
		end)
		
		--[[
		self.parent_element:attach(function() self:get_last_parent_element():render() end)
		self.source:attach(function() self:get_last_parent_element():render() end)
		self.position:attach(function() self:get_last_parent_element():render() end)
		self.size:attach(function() self:get_last_parent_element():render() end)
		self.rotation:attach(function() self:get_last_parent_element():render() end)
		self.buffer:attach(function() self:get_last_parent_element():render() end)
		self.wrapped:attach(function() self:get_last_parent_element():render() end)
		--]]
			
		self.parent_element:set_value(properties.parent_element)
		self.focused:set_value(true)
		
		--self:render()
	end
	
	function default_element:delete()
		self.parent_element:set_value(nil)
		for _,bind in pairs(self.binds) do bind:detach() end
	end
	
	function default_element:render() if self.visible.value==false then return end
		local global_color=self:get_global_color()
		self:get_current_buffer()
		self:get_absolute_rotation()
		self:get_absolute_position()
		self:get_absolute_size()
		self:get_wrap()
		self.pre_rendered:invoke()
		if self.background_color.value.a<1 or self.source_color.value.a<1 then
			thread.scheduler.platform:render_image(
				self.source.value,
				self.absolute_position.value,
				self.absolute_size.value,
				self.absolute_rotation.value,
				self.wrap.value,
				{
					r=self.background_color.value.r+global_color.r,
					g=self.background_color.value.g+global_color.g,
					b=self.background_color.value.b+global_color.b,
					a=self.background_color.value.a+global_color.a
				},
				{
					r=self.source_color.value.r+global_color.r,
					g=self.source_color.value.g+global_color.g,
					b=self.source_color.value.b+global_color.b,
					a=self.source_color.value.a+global_color.a
				},
				self.filter_mode.value,
				self.anistropy.value,
				self.current_buffer.value
			)
		end
		for i,child_element in pairs(self.child_elements.value) do
			if child_element.parent_element.value==self then
				child_element:render()
			else
				self.child_elements:remove_value(i)
			end
		end
	end
	
	function default_element:get_last_parent_element()
		local current_element=self
		if self.parent_element.value~=nil then
			current_element=self.parent_element.value:get_last_parent_element()
		end
		return current_element
	end
	
	function default_element:get_current_buffer()
		local current_buffer=self.buffer.value
		local current_parent=self.parent_element.value
		while current_buffer==nil and current_parent~=nil do
			current_buffer=current_parent.current_buffer.value
			current_parent=current_parent.parent_element.value
		end
		self.current_buffer:set_value(current_buffer)
		return current_buffer
	end
	
	function default_element:get_absolute_position()
		local parent_angle=0
		local parent_position={x=0;y=0;}
		local parent_resolution=thread.scheduler.platform:get_buffer_resolution(self.current_buffer.value)
		if self.parent_element.value~=nil then
			parent_angle=self.parent_element.value:get_absolute_rotation()
			parent_position=self.parent_element.value:get_absolute_position()
			parent_resolution=self.parent_element.value:get_absolute_size()
		end
		local current_position={
			x=(parent_resolution.x*self.position.value.scale.x)+self.position.value.offset.x+parent_position.x;
			y=(parent_resolution.y*self.position.value.scale.y)+self.position.value.offset.y+parent_position.y;
		}
		current_position=rotate_point(current_position,parent_position,parent_angle)
		if self.absolute_position.value.x~=current_position.x or self.absolute_position.value.y~=current_position.y then
			self.absolute_position:set_value(current_position)
		end
		return current_position
	end
	
	function default_element:get_absolute_size()
		local parent_resolution=thread.scheduler.platform:get_buffer_resolution(self.current_buffer.value)
		if self.parent_element.value~=nil then
			parent_resolution=self.parent_element.value:get_absolute_size()
		end
		local current_size={
			x=(parent_resolution.x*self.size.value.scale.x)+self.size.value.offset.x;
			y=(parent_resolution.y*self.size.value.scale.y)+self.size.value.offset.y;
		}
		if self.absolute_size.value.x~=current_size.x or self.absolute_size.value.y~=current_size.y then
			self.absolute_size:set_value(current_size)
		end
		return current_size
	end
	
	function default_element:get_absolute_rotation()
		local current_rotation=self.rotation.value
		if self.parent_element.value~=nil then
			current_rotation=current_rotation+self.parent_element.value:get_absolute_rotation()
		end
		self.absolute_rotation:set_value(current_rotation)
		return current_rotation
	end
	
	function default_element:get_wrap()
		local current_wrap={
			x1=self.absolute_position.value.x,y1=self.absolute_position.value.y,
			x2=self.absolute_position.value.x+self.absolute_size.value.x,y2=self.absolute_position.value.y+self.absolute_size.value.y
		}
		if self.wrapped.value==false then
			current_wrap={
				x1=0,y1=0,
				x2=thread.scheduler.platform.screen_resolution.value.x,y2=thread.scheduler.platform.screen_resolution.value.y
			}
		end
		local current_parent=self.parent_element.value
		while current_parent~=nil do
			if current_parent.wrapped.value==true then
				current_wrap=API:constrain_wrap(current_wrap,current_parent:get_wrap())
			end
			current_parent=current_parent.parent_element.value
		end
		if self.wrap.value.x1~=current_wrap.x1 or self.wrap.value.y1~=current_wrap.y1 or self.wrap.value.x2~=current_wrap.x2 or self.wrap.value.y2~=current_wrap.y2 then
			self.wrap:set_value(current_wrap)
		end
		return current_wrap
	end
	
	function default_element:update_render()
		if self.parent_element.value~=nil then
			self.parent_element.value:update_render()
		else
			self:render()
		end
	end
	
	function default_element:bump_z_index()
		if self.parent_element.value~=nil then
			for i,element in pairs(self.parent_element.value.child_elements.value) do
				if element==self then
					--table.remove(self.parent_element.value.child_elements.value,i) --Index out of bounds
					self.parent_element.value.child_elements.value[i]=nil
					table.insert(self.parent_element.value.child_elements.value,#self.parent_element.value.child_elements.value+1,self)
					break
				end
			end
		end
	end
	
	function default_element:get_descendants()
		local descendants_a=thread.libraries["stdlib"]:copy(self.child_elements.value)
		for _,element_a in pairs(descendants_a) do
			for _,element_b in pairs(element_a:get_descendants()) do
				table.insert(descendants_a,#descendants_a+1,element_b)
			end
		end
		return descendants_a
	end
	
	function default_element:get_focused_element()
		local focused
		local current_parent=self.parent_element.value
		while current_parent~=nil do
			focused=current_parent.focused.value
			current_parent=current_parent.parent_element.value
		end
		return focused
	end
	
	function default_element:get_global_color()
		local global_color=thread.libraries["stdlib"]:copy(self.global_color.value)
		if self.parent_element.value~=nil then
			local parent_global_color=self.parent_element.value:get_global_color()
			global_color.r=global_color.r+parent_global_color.r
			global_color.g=global_color.g+parent_global_color.g
			global_color.b=global_color.b+parent_global_color.b
			global_color.a=global_color.a+parent_global_color.a
		end
		return global_color
	end
	
	local slice_element=default_element:extend() --::::::::::::::::::::[Slice Element]::::::::::::::::::::
	function slice_element:__tostring() return "slice_element" end
	function slice_element:new(properties)
		slice_element.super.new(self,properties)
		
		self.slices=thread.libraries["eztask"]:create_property({})
		self.slice_type=thread.libraries["eztask"]:create_property(properties.slice_type or API.enum.slice_type.nine)
		self.slice_center=thread.libraries["eztask"]:create_property(properties.slice_center or {x1=0,y1=0,x2=0,y2=0})
		self.source_resolution=thread.libraries["eztask"]:create_property(properties.source_resolution or {x=0,y=0})
		self.slice_color=thread.libraries["eztask"]:create_property(properties.slice_color or {r=1,g=1,b=1,a=0})
		self.slice_source=thread.libraries["eztask"]:create_property(properties.slice_source)
		
		self.slice_box=default_element({
			parent_element=self;
			wrapped=self.wrapped.value;
			visible=true;
		})

		self.binds[#self.binds+1]=self.absolute_size:attach(function() self:update_slices() end)
		self.binds[#self.binds+1]=self.slice_color:attach(function() self:update_slices() end)
		self.binds[#self.binds+1]=self.slice_source:attach(function() self:update_slices() end)
		self.binds[#self.binds+1]=self.source_resolution:attach(function() self:update_slices() end)
		self.binds[#self.binds+1]=self.slice_center:attach(function() self:update_slices() end)
		self.binds[#self.binds+1]=self.slice_type:attach(function() self:render_slices() end)
		
		self:render_slices()
	end
	
	function slice_element:update_slices() --You got no idea how fucking long it took me to code this part
		if self.slice_source.value==nil then return end
		
		self.slice_box.wrapped:set_value(self.wrapped.value)
		self.slice_box.position:set_value({offset={x=self.slice_center.value.x1,y=self.slice_center.value.y1},scale={x=0,y=0}})
		self.slice_box.size:set_value({
			offset={
				x=-(self.source_resolution.value.x-self.slice_center.value.x2),
				y=-(self.source_resolution.value.y-self.slice_center.value.y2)
			},
			scale={x=1,y=1}
		})
		
		for i,slice in pairs(self.slices.value) do
			slice.element.source_color:set_value(self.slice_color.value)
			slice.element.source:set_value(self.slice_source.value)
			if self.slice_type.value==API.enum.slice_type.nine then
				if i==1 then
					slice.parent_element.position:set_value({offset={x=0,y=0},scale={x=0,y=0}})
					slice.parent_element.size:set_value({offset={x=self.slice_center.value.x1,y=self.slice_center.value.y1},scale={x=0,y=0}})
					slice.element.position:set_value({offset={x=0,y=0},scale={x=0,y=0}})
					slice.element.size:set_value({offset={x=self.source_resolution.value.x,y=self.source_resolution.value.y},scale={x=0,y=0}})
				elseif i==2 then
					slice.parent_element.position:set_value({offset={x=self.slice_center.value.x1,y=0},scale={x=0,y=0}})
					slice.parent_element.size:set_value({offset={x=-(self.slice_center.value.x1+(self.source_resolution.value.x-self.slice_center.value.x2)),y=self.slice_center.value.y1},scale={x=1,y=0}})
					slice.element.position:set_value({offset={x=0,y=0},scale={x=-self.slice_center.value.x1/self.source_resolution.value.x,y=0}})
					slice.element.size:set_value({offset={x=0,y=self.source_resolution.value.y},scale={x=1+((self.slice_center.value.x1+(self.source_resolution.value.x-self.slice_center.value.x2))/self.source_resolution.value.x),y=0}})
				elseif i==3 then
					slice.parent_element.position:set_value({offset={x=-(self.source_resolution.value.x-self.slice_center.value.x2),y=0},scale={x=1,y=0}})
					slice.parent_element.size:set_value({offset={x=self.source_resolution.value.x-self.slice_center.value.x2,y=self.slice_center.value.y1},scale={x=0,y=0}})
					slice.element.position:set_value({offset={x=-self.source_resolution.value.x+(self.source_resolution.value.x-self.slice_center.value.x2),y=0},scale={x=0,y=0}})
					slice.element.size:set_value({offset={x=self.source_resolution.value.x,y=self.source_resolution.value.y},scale={x=0,y=0}})
				elseif i==4 then
					slice.parent_element.position:set_value({offset={x=0,y=self.slice_center.value.y1},scale={x=0,y=0}})
					slice.parent_element.size:set_value({offset={x=self.slice_center.value.x1,y=-(self.slice_center.value.y1+(self.source_resolution.value.y-self.slice_center.value.y2))},scale={x=0,y=1}})
					slice.element.position:set_value({offset={x=0,y=0},scale={x=0,y=-self.slice_center.value.y1/self.source_resolution.value.y}})
					slice.element.size:set_value({offset={x=self.source_resolution.value.x,y=0},scale={x=0,y=1+((self.slice_center.value.y1+(self.source_resolution.value.y-self.slice_center.value.y2))/self.source_resolution.value.y)}})
				elseif i==5 then
					slice.parent_element.position:set_value({offset={x=self.slice_center.value.x1,y=self.slice_center.value.y1},scale={x=0,y=0}})
					slice.parent_element.size:set_value({offset={x=-(self.slice_center.value.x1+(self.source_resolution.value.x-self.slice_center.value.x2)),y=-(self.slice_center.value.y1+(self.source_resolution.value.y-self.slice_center.value.y2))},scale={x=1,y=1}})
					slice.element.position:set_value({offset={x=0,y=0},scale={x=-self.slice_center.value.x1/self.source_resolution.value.x,y=-self.slice_center.value.y1/self.source_resolution.value.y}})
					slice.element.size:set_value({offset={x=0,y=0},scale={x=1+((self.slice_center.value.x1+(self.source_resolution.value.x-self.slice_center.value.x2))/self.source_resolution.value.x),y=1+((self.slice_center.value.y1+(self.source_resolution.value.y-self.slice_center.value.y2))/self.source_resolution.value.y)}})
				elseif i==6 then
					slice.parent_element.position:set_value({offset={x=-(self.source_resolution.value.x-self.slice_center.value.x2),y=self.slice_center.value.y1},scale={x=1,y=0}})
					slice.parent_element.size:set_value({offset={x=self.source_resolution.value.x-self.slice_center.value.x2,y=-(self.slice_center.value.y1+(self.source_resolution.value.y-self.slice_center.value.y2))},scale={x=0,y=1}})
					slice.element.position:set_value({offset={x=-self.source_resolution.value.x+(self.source_resolution.value.x-self.slice_center.value.x2),y=0},scale={x=0,y=-self.slice_center.value.y1/self.source_resolution.value.y}})
					slice.element.size:set_value({offset={x=self.source_resolution.value.x,y=0},scale={x=0,y=1+((self.slice_center.value.y1+(self.source_resolution.value.y-self.slice_center.value.y2))/self.source_resolution.value.y)}})
				elseif i==7 then
					slice.parent_element.position:set_value({offset={x=0,y=-(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=0,y=1}})
					slice.parent_element.size:set_value({offset={x=self.slice_center.value.x1,y=(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=0,y=0}})
					slice.element.position:set_value({offset={x=0,y=-self.source_resolution.value.y+(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=0,y=0}})
					slice.element.size:set_value({offset={x=self.source_resolution.value.x,y=self.source_resolution.value.y},scale={x=0,y=0}})
				elseif i==8 then
					slice.parent_element.position:set_value({offset={x=self.slice_center.value.x1,y=-(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=0,y=1}})
					slice.parent_element.size:set_value({offset={x=-(self.slice_center.value.x1+(self.source_resolution.value.x-self.slice_center.value.x2)),y=(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=1,y=0}})
					slice.element.position:set_value({offset={x=0,y=-self.source_resolution.value.y+(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=-self.slice_center.value.x1/self.source_resolution.value.x,y=0}})
					slice.element.size:set_value({offset={x=0,y=self.source_resolution.value.y},scale={x=1+((self.slice_center.value.x1+(self.source_resolution.value.x-self.slice_center.value.x2))/self.source_resolution.value.x),y=0}})
				elseif i==9 then
					slice.parent_element.position:set_value({offset={x=-(self.source_resolution.value.x-self.slice_center.value.x2),y=-(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=1,y=1}})
					slice.parent_element.size:set_value({offset={x=(self.source_resolution.value.x-self.slice_center.value.x2),y=(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=0,y=0}})
					slice.element.position:set_value({offset={x=-self.source_resolution.value.x+(self.source_resolution.value.x-self.slice_center.value.x2),y=-self.source_resolution.value.y+(self.source_resolution.value.y-self.slice_center.value.y2)},scale={x=0,y=0}})
					slice.element.size:set_value({offset={x=self.source_resolution.value.x,y=self.source_resolution.value.y},scale={x=0,y=0}})
				end
			end
		end
	end
	
	function slice_element:render_slices()
		for _,slice in pairs(self.slices.value) do
			slice.parent_element.parent_element.value=nil
		end
		self.slices:set_value({})
		if self.slice_type.value==API.enum.slice_type.nine then
			for i=1,9 do
				local parent_element=API.elements.default_element({
					parent_element=self;
					wrapped=true;
					visible=true;
				})
				local element=API.elements.default_element({
					parent_element=parent_element;
					wrapped=true;
					background_color={r=0,g=0,b=0,a=1};
					source_color=self.slice_color.value;
					source=self.slice_source.value;
					visible=true;
				})
				local slice={parent_element=parent_element,element=element}
				table.insert(self.slices.value,#self.slices.value+1,slice)
			end
		end
		self:update_slices()
	end
	
	local text_element=default_element:extend() --::::::::::::::::::::[Text Element]::::::::::::::::::::
	function text_element:__tostring() return "text_element" end
	function text_element:new(properties)
		text_element.super.new(self,properties)
		
		self.text=thread.libraries["eztask"]:create_property(properties.text or "")
		self.font=thread.libraries["eztask"]:create_property(properties.font)
		self.font_size=thread.libraries["eztask"]:create_property(properties.font_size or 8)
		self.text_color=thread.libraries["eztask"]:create_property(properties.text_color or {r=1,g=1,b=1,a=0})
		self.text_scaled=thread.libraries["eztask"]:create_property(properties.text_scaled or false)
		self.text_alignment=thread.libraries["eztask"]:create_property(properties.text_alignment or {x=API.enum.text_alignment.x.center,y=API.enum.text_alignment.y.center})
		self.multi_line=thread.libraries["eztask"]:create_property(properties.multi_line or false)
	end
	
	function text_element:render()
		text_element.super.render(self)
		local font_size=self.font_size.value
		local global_color=self:get_global_color()
		if self.text_scaled.value==true then
			font_size=floor(self.absolute_size.value.y*5/6)
		end
		thread.scheduler.platform:render_text(
			self.text.value,
			self.absolute_position.value,
			self.wrap.value,
			self.wrapped.value,
			{r=self.text_color.value.r+global_color.r,g=self.text_color.value.g+global_color.g,b=self.text_color.value.b+global_color.b,a=self.text_color.value.a+global_color.a},
			self.text_alignment.value,
			self.font.value,
			font_size,
			self.current_buffer.value
		)
	end

	local text_image_element=default_element:extend() --::::::::::::::::::::[Text Image Element]::::::::::::::::::::
	function text_image_element:__tostring() return "text_image_element" end
	function text_image_element:new(properties)
		text_image_element.super.new(self,properties)
		
		self.text=thread.libraries["eztask"]:create_property(properties.text or "")
		self.char_elements=thread.libraries["eztask"]:create_property({})
		self.font=thread.libraries["eztask"]:create_property(properties.font)
		self.font_size=thread.libraries["eztask"]:create_property(properties.font_size or 8)
		self.text_color=thread.libraries["eztask"]:create_property(properties.text_color or {r=1,g=1,b=1,a=0})
		self.text_scaled=thread.libraries["eztask"]:create_property(properties.text_scaled or false)
		self.text_alignment=thread.libraries["eztask"]:create_property(properties.text_alignment or {x=API.enum.text_alignment.x.center,y=API.enum.text_alignment.y.center})
		self.multi_line=thread.libraries["eztask"]:create_property(properties.multi_line or false)
		
		self.binds[#self.binds+1]=self.text:attach(function() self:render_text() end)
		self.binds[#self.binds+1]=self.font:attach(function() self:render_text() end)
		self.binds[#self.binds+1]=self.text_color:attach(function() self:update_text_color() end)
		self.binds[#self.binds+1]=self.size:attach(function() self:update_text_size_and_position() end)
		self.binds[#self.binds+1]=self.position:attach(function() self:update_text_size_and_position() end)
		self.binds[#self.binds+1]=self.pre_rendered:attach(function() self:update_text_size_and_position() end)

		self:render_text()
	end
	
	function text_image_element:update_text_color()
		for i,char_element in pairs(self.char_elements.value) do
			char_element.element.color:set_value(self.text_color.value)
		end
	end
	
	function text_image_element:update_text_size_and_position()
		for i,char_element in pairs(self.char_elements.value) do
			char_element.element.size:set_value({
				offset={x=0,y=0},
				scale={x=self.font.value.structure.map_size.x,y=self.font.value.structure.map_size.y}
			})
			if self.text_scaled.value==true then
				local absolute_size=self:get_absolute_size()
				self.font_size.value=absolute_size.x/#self.char_elements.value
				if self.font_size.value*self.font.value.structure.size_ratio>absolute_size.y then
					self.font_size.value=absolute_size.y/self.font.value.structure.size_ratio
				end
			end
			char_element.parent_element.size:set_value({
				offset={x=self.font_size.value,y=self.font_size.value*self.font.value.structure.size_ratio},
				scale={x=0,y=0}
			})
			if self.text_alignment.value.x==API.enum.text_alignment.x.center then
				char_element.parent_element.position.value.offset.x=-((#self.char_elements.value/2)-(i-1))*self.font_size.value
				char_element.parent_element.position.value.scale.x=0.5
			elseif self.text_alignment.value.x==API.enum.text_alignment.x.left then
				char_element.parent_element.position.value.offset.x=(i-1)*self.font_size.value
				char_element.parent_element.position.value.scale.x=0
			elseif self.text_alignment.value.x==API.enum.text_alignment.x.right then
				char_element.parent_element.position.value.offset.x=-((#self.char_elements.value-i)*self.font_size.value)-self.font_size.value
				char_element.parent_element.position.value.scale.x=1
			end
			if self.text_alignment.value.y==API.enum.text_alignment.y.center then
				char_element.parent_element.position.value.offset.y=-(self.font_size.value*self.font.value.structure.size_ratio)/2
				char_element.parent_element.position.value.scale.y=0.5
			elseif self.text_alignment.value.y==API.enum.text_alignment.y.top then
				char_element.parent_element.position.value.offset.y=0
				char_element.parent_element.position.value.scale.y=0
			elseif self.text_alignment.value.y==API.enum.text_alignment.y.bottom then
				char_element.parent_element.position.value.offset.y=-(self.font_size.value*self.font.value.structure.size_ratio)
				char_element.parent_element.position.value.scale.y=1
			end
		end
	end

	function text_image_element:render_text()
		for _,char_element in pairs(self.char_elements.value) do
			char_element.parent_element:delete()
		end
		self.char_elements:set_value({})
		if self.font.value~=nil and self.text.value~=nil then
			for i=1,string.len(self.text.value) do
				local character=string.sub(self.text.value,i,i)
				local char_parent_element=API.elements.default_element({
					parent_element=self;
					source_color={r=1,g=1,b=1,a=0};
					visible=true;
					wrapped=false;
				});
				local offset_parent_element=API.elements.default_element({
					parent_element=char_parent_element;
					source_color={r=1,g=1,b=1,a=1};
					size={offset={x=0,y=0},scale={x=1,y=1}};
					visible=true;
					wrapped=true;
				});
				local char_sprite_sheet=API.elements.default_element({
					parent_element=offset_parent_element;
					source=self.font.value.source;
					visible=true;
					wrapped=false;
					filter_mode=thread.scheduler.platform.enum.filter_mode.nearest;
					position={
						offset={x=0,y=0};
						scale=API:calculate_char_offset(self.font.value,character);
					};
				});
				local char_element={
					parent_element=char_parent_element;
					offset_parent_element=offset_parent_element;
					element=char_sprite_sheet;
				}
				self.char_elements:add_value(char_element)
			end
		end
		self:update_text_size_and_position()
		self:update_text_color()
	end
	
	API.elements.default_element=default_element
	API.elements.text_element=text_element
	API.elements.text_image_element=text_image_element
	API.elements.slice_element=slice_element

	return API
end