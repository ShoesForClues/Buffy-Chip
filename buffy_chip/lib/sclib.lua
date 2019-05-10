--[[************************************************************

	Simple Collision written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,0,3};
		_dependencies={
			"stdlib";
		};
	};
	
	function API:resolve_collision_1d(pos_1,size_1,pos_2,size_2) --1D calculation
		local collided,new_pos=false,pos_1
		if pos_1<pos_2 and pos_1+size_1>pos_2 then
			new_pos=pos_2-size_1
			collided=true
		elseif pos_1<pos_2+size_2 and pos_1+size_1>pos_2+size_2 then
			new_pos=pos_2+size_2
			collided=true
		elseif pos_1<=pos_2 and pos_1+size_1>=pos_2+size_2 then
			collided=true
		end
		return collided,new_pos
	end
	
	function API:resolve_collision_2d(obj_pos,obj_size,wall_pos,wall_size)
		local new_position=obj_pos
		local collided_x,new_x=API:resolve_collision_1d(obj_pos.x,obj_size.x,wall_pos.x,wall_size.x)
		local collided_y,new_y=API:resolve_collision_1d(obj_pos.y,obj_size.y,wall_pos.y,wall_size.y)
		return (collided_x and collided_y),{x=new_x,y=new_y}
	end
	
	return API
end