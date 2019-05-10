--[[************************************************************

	Tile Map Engine written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,1,0};
		_dependencies={
			"stdlib";
			"gel";
			"geffects";
			"easing";
			"sclib";
		};
	};
	
	function API:is_in_viewport(start_position,position,camera_position,view_port_tile_resolution)
		return position.x>=start_position.x-1 and position.y>=start_position.y-1 and position.x<=camera_position.x+(view_port_tile_resolution.x/2)+1 and position.y<=camera_position.y+(view_port_tile_resolution.y/2)+1
	end
	
	function API:allocate_tile(world,x,y)
		if world.map[y]==nil then
			world.map[y]={}
		end
		if world.map[y][x]==nil then
			world.map[y][x]={}
		end
	end
	
	function API:unallocate_tile(world,x,y)
		if world.map[y]~=nil and world.map[y][x]~=nil then
			world.map[y][x]=nil
		end
	end
	
	function API:check_object_collision(object,neighbor_tile)
		if object==nil or neighbor_tile==nil or object.anchored.value==true then return end
		local collided=false
		for _,neighbor_object in pairs(neighbor_tile) do
			if neighbor_object~=object then
				collided=thread.libraries["sclib"]:resolve_collision_2d(object.position.value,object.size.value,neighbor_object.position.value,neighbor_object.size.value)
				if collided==true then
					object.touched:invoke(neighbor_object)
				end
			end
		end
		return collided
	end
	
	function API:check_local_collision(world,object,tile_position)
		return (API:check_object_collision(object,world:get_tile(tile_position.x-1,tile_position.y-1))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x,tile_position.y-1))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x+1,tile_position.y-1))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x-1,tile_position.y))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x,tile_position.y))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x+1,tile_position.y))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x-1,tile_position.y+1))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x,tile_position.y+1))==true or
		API:check_object_collision(object,world:get_tile(tile_position.x+1,tile_position.y+1))==true)
	end
	
	function API:update_object_physics(world,object,frame_time)
		if world==nil or object==nil or object.anchored.value==true then return end
		object.velocity:set_value({
			x=object.velocity.value.x+(frame_time*world.global.gravity.value.x);
			y=thread.libraries["stdlib"]:clamp(object.velocity.value.y+(frame_time*world.global.gravity.value.y),-math.huge,object.terminal_velocity.value);
		})
		
		local old_position=object.position.value
		object.position:set_value({
			x=object.position.value.x+(object.velocity.value.x*frame_time);
			y=object.position.value.y;
		})
		local tile_position={
			x=thread.libraries["stdlib"].root_functions.math.floor(object.position.value.x);
			y=thread.libraries["stdlib"].root_functions.math.floor(object.position.value.y);
		}
		if API:check_local_collision(world,object,tile_position)==true then
			object.position:set_value(old_position)
		end
		old_position=object.position.value
		object.position:set_value({
			x=object.position.value.x;
			y=object.position.value.y+(object.velocity.value.y*frame_time);
		})
		tile_position={
			x=thread.libraries["stdlib"].root_functions.math.floor(object.position.value.x);
			y=thread.libraries["stdlib"].root_functions.math.floor(object.position.value.y);
		}
		if API:check_local_collision(world,object,tile_position)==true then
			object.position:set_value(old_position)
		end
	end
	
	function API:update_world(world)
		local duration=thread.scheduler.platform:get_tick()-world.runtime.last_update_tick
		world:tween_camera()
		
		local start_pos={
			x=world.camera.current_position.value.x-(world.view_port_tile_resolution.value.x/2);
			y=world.camera.current_position.value.y-(world.view_port_tile_resolution.value.y/2);
		}
		local start_pos_rounded={
			x=thread.libraries["stdlib"]:round(world.camera.current_position.value.x-(world.view_port_tile_resolution.value.x/2))-1;
			y=thread.libraries["stdlib"]:round(world.camera.current_position.value.y-(world.view_port_tile_resolution.value.y/2))-1;
		}
		
		for _,background in pairs(world.backgrounds) do
			background.element.position:set_value({
				offset={x=0,y=0};
				scale={x=-world.camera.current_position.value.x*background.camera_offset_percent.value,y=0};
			})
		end
		
		for _,element in pairs(world.view_port.tile_map:get_descendants()) do
			if element.linked_object~=nil then
				if API:is_in_viewport(start_pos_rounded,element.linked_object.position.value,world.camera.current_position.value,world.view_port_tile_resolution.value)==true then
					element.position:set_value({
						offset={x=0,y=0};
						scale={x=(element.linked_object.position.value.x-start_pos.x)/world.view_port_tile_resolution.value.x,y=(element.linked_object.position.value.y-start_pos.y)/world.view_port_tile_resolution.value.y};
					})
				else
					--element.render_thread.runtime.run_state:set_value(false)
					element.parent_element:set_value(nil)
				end
			end
		end
		for y=start_pos_rounded.y,start_pos_rounded.y+world.view_port_tile_resolution.value.y+1 do
			for x=start_pos_rounded.x,start_pos_rounded.x+world.view_port_tile_resolution.value.x+1 do
				if world.map[y]~=nil and world.map[y][x]~=nil then
					for i,object in pairs(world.map[y][x]) do
						if thread.libraries["stdlib"].root_functions.math.floor(object.position.value.x)~=x or thread.libraries["stdlib"].root_functions.math.floor(object.position.value.y)~=y then
							table.remove(world.map[y][x],i)
						else
							--element.render_thread.runtime.run_state:set_value(true)
							API:update_object_physics(world,object,0.03)
							object.linked_element.position:set_value({
								offset={x=0,y=0};
								scale={x=(object.position.value.x-start_pos.x)/world.view_port_tile_resolution.value.x,y=(object.position.value.y-start_pos.y)/world.view_port_tile_resolution.value.y};
							})
							object.linked_element.parent_element:set_value(world.view_port.tile_map)
						end
					end
					if #world.map[y][x]<=0 then
						API:unallocate_tile(world,x,y)
					end
					--print("Size: "..tostring(tile.linked_element.size.value.scale.x)..","..tostring(tile.linked_element.size.value.scale.y))
					--print("Position: "..tostring(tile.linked_element.position.value.scale.x)..","..tostring(tile.linked_element.position.value.scale.y))
				end
				if world.map[start_pos_rounded.y+world.view_port_tile_resolution.value.y-(y-1)]~=nil then --Fix tile layering
					if world.map[start_pos_rounded.y+world.view_port_tile_resolution.value.y-(y-1)][start_pos_rounded.x+world.view_port_tile_resolution.value.x-(x-1)]~=nil then
						for _,object in pairs(world.map[start_pos_rounded.y+world.view_port_tile_resolution.value.y-(y-1)][start_pos_rounded.x+world.view_port_tile_resolution.value.x-(x-1)]) do
							object.linked_element:bump_z_index()
						end
					end
				end
			end
		end
		world.runtime.last_update_tick=thread.scheduler.platform:get_tick()
	end
	
	function API:create_world(properties)
		if properties==nil then return end
		
		local world={
			view_port_tile_resolution=thread.libraries["stdlib"]:create_property(properties.view_port_tile_resolution or {x=12,y=8});
			camera={
				goal_position=thread.libraries["stdlib"]:create_property(properties.camera_position or {x=6,y=4});
				current_position=thread.libraries["stdlib"]:create_property(properties.camera_position or {x=6,y=4});
				easing_style=thread.libraries["stdlib"]:create_property(properties.camera_easing_style or thread.libraries["easing"].outQuad);
				easing_speed=thread.libraries["stdlib"]:create_property(properties.camera_easing_speed or 10);
			};
			global={
				gravity=thread.libraries["stdlib"]:create_property(properties.gravity or {x=0,y=0});
			};
			runtime={
				last_update_tick=thread.scheduler.platform:get_tick();
			};
			view_port=thread.libraries["gel"].elements.default_element({
				parent_element=properties.parent_element;
				size={
					offset={x=0,y=0};
					scale={x=1,y=1};
				};
				position={
					offset={x=0,y=0};
					scale={x=0,y=0};
				};
				color={r=0,g=0,b=0};
				opacity=1;
				wrapped=true;
				visible=true;
			});
			backgrounds={};
			object_pack={};
			map={};
		}
		
		world.view_port.background_map=thread.libraries["gel"].elements.default_element({
			parent_element=world.view_port;
			size={
				offset={x=0,y=0};
				scale={x=1,y=1};
			};
			position={
				offset={x=0,y=0};
				scale={x=0,y=0};
			};
			color={r=0,g=0,b=0};
			opacity=1;
			wrapped=false;
			visible=true;
		});
		world.view_port.tile_map=thread.libraries["gel"].elements.default_element({
			parent_element=world.view_port;
			size={
				offset={x=0,y=0};
				scale={x=1,y=1};
			};
			position={
				offset={x=0,y=0};
				scale={x=0,y=0};
			};
			color={r=0,g=0,b=0};
			opacity=1;
			wrapped=false;
			visible=true;
		});
		
		function world:get_tile(x,y)
			x=thread.libraries["stdlib"].root_functions.math.floor(x)
			y=thread.libraries["stdlib"].root_functions.math.floor(y)
			local tile
			if world.map[y]~=nil and world.map[y][x]~=nil then
				tile=world.map[y][x]
			end
			return tile
		end

		function world:tween_camera()
			world.camera.current_position:set_value({
				x=thread.libraries["geffects"]:calculate_tween(world.camera.current_position.value.x,world.camera.goal_position.value.x,world.camera.easing_speed.value,world.camera.easing_style.value);
				y=thread.libraries["geffects"]:calculate_tween(world.camera.current_position.value.y,world.camera.goal_position.value.y,world.camera.easing_speed.value,world.camera.easing_style.value);
			})
		end
		
		function world:add_background(properties,index)
			local background={
				source=thread.libraries["stdlib"]:create_property(properties.source);
				size=thread.libraries["stdlib"]:create_property(properties.size or 1);
				tile_resolution=thread.libraries["stdlib"]:create_property(properties.tile_resolution or 1);
				camera_offset_percent=thread.libraries["stdlib"]:create_property(properties.camera_offset_percent or 0.01);
				color=thread.libraries["stdlib"]:create_property(properties.color or {r=1,g=1,b=1});
				opacity=thread.libraries["stdlib"]:create_property(properties.opacity or 0);
			};
			background.element=thread.libraries["gel"].elements.default_element({
				parent_element=world.view_port.background_map;
				size={
					offset={x=0,y=0};
					scale={x=background.size.value*background.tile_resolution.value,y=1};
				};
				position={
					offset={x=0,y=0};
					scale={x=-world.camera.current_position.value.x*background.camera_offset_percent.value,y=0};
				};
				color={r=0,g=0,b=0};
				opacity=1;
				wrapped=true;
				visible=true;
			});
			for i=1,background.tile_resolution.value do
				thread.libraries["gel"].elements.default_element({
					parent_element=background.element;
					source=background.source.value;
					size={
						offset={x=0,y=0};
						scale={x=1/background.tile_resolution.value,y=1};
					};
					position={
						offset={x=0,y=0};
						scale={x=(i-1)*background.tile_resolution.value,y=0};
					};
					color=background.color.value;
					opacity=background.opacity.value;
					wrapped=false;
					visible=true;
				})
			end
			world.backgrounds[index or #world.backgrounds+1]=background
			return background
		end
		
		function world:add_object_type(object,index)
			if object==nil then return end
			object.properties=object.properties or {}
			local object_type={
				render_function=object.render_function or function(object) end;
				default_properties={
					collidable=object.properties.collidable or true;
					anchored=object.properties.anchored or true;
					size=object.properties.size or {x=1,y=1};
					terminal_velocity=object.properties.terminal_velocity or math.huge;
				};
			}
			world.object_pack[index or #world.object_pack]=object_type
			return object_type
		end
		
		function world:add_object(properties)
			if properties==nil or properties.position==nil then return end
			
			local object
			local object_type=world.object_pack[properties.object_type_index]
			if object_type~=nil then
				if properties.anchored==nil then
					properties.anchored=object_type.default_properties.anchored
				end
			
				local tile_position={x=thread.libraries["stdlib"].root_functions.math.floor(properties.position.x),y=thread.libraries["stdlib"].root_functions.math.floor(properties.position.y)}
				object={
					linked_element=nil;
					object_type_index=properties.object_type_index;
					
					size=thread.libraries["stdlib"]:create_property(properties.size or object_type.default_properties.size);
					position=thread.libraries["stdlib"]:create_property(properties.position);
					collidable=thread.libraries["stdlib"]:create_property(properties.collidable or object_type.default_properties.collidable);
					anchored=thread.libraries["stdlib"]:create_property(properties.anchored);
					velocity=thread.libraries["stdlib"]:create_property(properties.velocity or {x=0,y=0});
					terminal_velocity=thread.libraries["stdlib"]:create_property(properties.terminal_velocity or object_type.default_properties.terminal_velocity);
					
					touched=thread.libraries["stdlib"]:create_signal(); --returns object that touched it
				}
				
				object.linked_element=thread.libraries["gel"].elements.default_element({
					size={
						offset={x=0,y=0};
						scale={x=1/world.view_port_tile_resolution.value.x,y=1/world.view_port_tile_resolution.value.y};
					};
					color={r=0,g=0,b=0};
					opacity=1;
					wrapped=false;
					visible=true;
				})
				object.linked_element.linked_object=object
				if world.object_pack[object.object_type_index].render_function~=nil then
					object.linked_element.render_thread=thread:create_thread(function(thread)
						world.object_pack[object.object_type_index].render_function(object)
					end)
				end
				
				--[[
				if world.tile_pack[tile.tile_type].script~=nil then
					thread:create_thread(function(thread)
						world.tile_pack[tile.tile_type].script(tile)
					end)
				end
				--]]
				
				object.position:attach_bind(function(position,old_position)
					local tile_position={x=thread.libraries["stdlib"].root_functions.math.floor(position.x),y=thread.libraries["stdlib"].root_functions.math.floor(position.y)}
					local old_tile_position={x=thread.libraries["stdlib"].root_functions.math.floor(old_position.x),y=thread.libraries["stdlib"].root_functions.math.floor(old_position.y)}
					if world.map[old_tile_position.y]~=nil and world.map[old_tile_position.y][old_tile_position.x]~=nil then
						for i,current_object in pairs(world.map[old_tile_position.y][old_tile_position.x]) do
							if current_object==object then
								world.map[old_tile_position.y][old_tile_position.x][i]=nil
								--table.remove(world.map[old_tile_position.y][old_tile_position.x],i)
								break
							end
						end
					end
					API:allocate_tile(world,tile_position.x,tile_position.y)
					world.map[tile_position.y][tile_position.x][#world.map[tile_position.y][tile_position.x]+1]=object
				end)
				
				API:allocate_tile(world,tile_position.x,tile_position.y)
				world.map[tile_position.y][tile_position.x][#world.map[tile_position.y][tile_position.x]+1]=object
			end
			return object
		end
		
		if properties.backgrounds~=nil then
			for i,background in pairs(properties.backgrounds) do
				world:add_background(background,i)
			end
		end
		
		if properties.object_packs~=nil then
			for _,pack in pairs(properties.object_packs) do
				for i,object_type in pairs(pack) do
					world:add_object_type(object_type,i)
				end
			end
		end
		
		if properties.object_maps~=nil then
			for _,map in pairs(properties.object_maps) do
				for y=1,#map do
					for x=1,#map[y] do
						world:add_object({
							position={x=x,y=y};
							object_type_index=map[y][x];
						})
					end
				end
			end
		end
		
		return world
	end
	
	return API
end