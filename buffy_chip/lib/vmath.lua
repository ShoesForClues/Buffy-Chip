--Vector math library by Jason Lee

return function(thread)
	local API={
		_version={0,1,3};
		_dependencies={
			"stdlib";
		};
		math={
			sin=thread.libraries["stdlib"].root_functions.math.sin;
			cos=thread.libraries["stdlib"].root_functions.math.cos;
			tan=thread.libraries["stdlib"].root_functions.math.tan;
			rad=thread.libraries["stdlib"].root_functions.math.rad;
			sqrt=thread.libraries["stdlib"].root_functions.math.sqrt;
			abs=thread.libraries["stdlib"].root_functions.math.abs;
		};
	}
	
	function API:transform_matrix_v3_v2(camera_position,camera_orientation,position,resolution,fov_matrix)
		local x,y,z=position[1]-camera_position[1],position[2]-camera_position[2],position[3]-camera_position[3]
		local ox,oy,oz=camera_orientation[1],camera_orientation[2],camera_orientation[3]
		
		local ox_cos,ox_sin=API.math.cos(ox),API.math.sin(ox)
		local oy_cos,oy_sin=API.math.cos(oy),API.math.sin(oy)
		local oz_cos,oz_sin=API.math.cos(oz),API.math.sin(oz)
		
		local d={
			oy_cos*(oz_sin*y+oz_cos*x)-oy_sin*z;
			ox_sin*(oy_cos*z+oy_sin*(oz_sin*y+oz_cos*x))+ox_cos*(oz_cos*y-oz_sin*x);
			ox_cos*(oy_cos*z+oy_sin*(oz_sin*y+oz_cos*x))-ox_sin*(oz_cos*y-oz_sin*x);
		}

		local b={
			((fov_matrix[3]*d[1])/d[3])-fov_matrix[1];
			((fov_matrix[3]*d[2])/d[3])-fov_matrix[2];
			API.math.sqrt((camera_position[1]-position[1])^2+(camera_position[2]-position[2])^2+(camera_position[3]-position[3])^2);
		}

		return b,(d[3]<0 and b[1]>=0 and b[1]<resolution.x and b[2]>=0 and b[2]<resolution.y),d[3]
	end
	
	function API:get_angle_vector(orientation)
		local sin_yaw,cos_yaw=API.math.sin(orientation[2]),API.math.cos(orientation[2])
		local sin_pitch,cos_pitch=API.math.sin(orientation[1]),API.math.cos(orientation[1])
		return {cos_pitch*cos_yaw,cos_pitch*sin_yaw,-sin_pitch}
	end
	
	function API:cross_v3(v1,v2)
		return {v1[2]*v2[3]-v1[3]*v2[2],v1[3]*v2[1]-v1[1]*v2[3],v1[1]*v2[2]-v1[2]*v2[1]}
	end
	
	function API:dot_v3(v1,v2)
		return v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3]
	end
	
	function API:add_v3(v1,v2)
		return {v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3]}
	end
	
	function API:subtract_v3(v1,v2)
		return {v1[1]-v2[1],v1[2]-v2[2],v1[3]-v2[3]}
	end
	
	function API:multiply_v3(v1,v2)
		if type(v2)=="table" then
			return {v1[1]*v2[1],v1[2]*v2[2],v1[3]*v2[3]}
		else
			return {v1[1]*v2,v1[2]*v2,v1[3]*v2}
		end
	end
	
	function API:divide_v3(v1,v2)
		if type(v2)=="table" then
			return {v1[1]/v2[1],v1[2]/v2[2],v1[3]/v2[3]}
		else
			return {v1[1]/v2,v1[2]/v2,v1[3]/v2}
		end
	end
	
	function API:vector_to_world_space(orientation,va)
		local vb={0,0,0}
		vb[1]=vb[1]-va[3]*API.math.cos(orientation[2])
		vb[3]=vb[3]+va[3]*API.math.sin(orientation[2])
		
		vb[3]=vb[3]-va[1]*API.math.cos(orientation[2])*API.math.cos(orientation[1])
		vb[1]=vb[1]-va[1]*API.math.sin(orientation[2])*API.math.cos(orientation[1])
		vb[2]=vb[2]+va[1]*API.math.sin(orientation[1])
		
		
		return vb
	end
	
	function API:rotate_v3(point,position,orientation)
		local new_point=API:subtract_v3(point,position)
		local x=new_point[1]*API.math.cos(orientation[1])-new_point[3]*API.math.sin(orientation[1])
		local z=new_point[3]*API.math.cos(orientation[1])+new_point[1]*API.math.sin(orientation[1])
		new_point[1],new_point[3]=x,z
		local y=new_point[2]*API.math.cos(orientation[2])-new_point[3]*API.math.sin(orientation[2])
		z=new_point[3]*API.math.cos(orientation[2])+new_point[2]*API.math.sin(orientation[2])
		new_point[2],new_point[3]=y,z
		x=new_point[1]*API.math.cos(orientation[3])-new_point[2]*API.math.sin(orientation[3])
		y=new_point[1]*API.math.sin(orientation[3])+new_point[2]*API.math.cos(orientation[3])
		new_point[1],new_point[2]=x,y
		return API:add_v3(new_point,position)
	end
	
	function API:get_midpoint_v3(vertices)
		local midpoint={0,0,0}
		for _,vertice in pairs(vertices) do
			midpoint=API:add_v3(midpoint,vertice)
		end
		return API:divide_v3(midpoint,#vertices)
	end
	
	function API:get_magnitude_v3(v)
		return API.math.sqrt(v[1]^2+v[2]^2+v[3]^2)
	end
	
	function API:get_unit_v3(v)
		return API:divide_v3(v,API:get_magnitude_v3(v))
	end
	
	function API:get_normal_v3(v1,v2,v3)
		local d1={v2[1]-v1[1],v2[2]-v1[2],v2[3]-v1[3]}
		local d2={v3[1]-v2[1],v3[2]-v2[2],v3[3]-v2[3]}
		local cross=API:cross_v3(d1,d2)
		local dist=API.math.sqrt(cross[1]^2+cross[2]^2+cross[3]^2)
		return API:divide_v3(cross,dist)
	end
	
	function API:add_v4(v1,v2)
		return {v1[1]+v2[1],v1[2]+v2[2],v1[3]+v2[3],v1[4]+v2[4]}
	end
	
	function API:multiply_v4(v1,v2)
		if type(v2)=="table" then
			return {v1[1]*v2[1],v1[2]*v2[2],v1[3]*v2[3],v1[4]*v2[4]}
		else
			return {v1[1]*v2,v1[2]*v2,v1[3]*v2,v1[4]*v2}
		end
	end
	
	function API:get_midpoint_v4(vertices)
		local midpoint={0,0,0,0}
		for _,vertice in pairs(vertices) do
			midpoint=API:add_v4(midpoint,vertice)
		end
		return API:divide_v4(midpoint,#vertices)
	end
	
	function API:divide_v4(v1,v2)
		if type(v2)=="table" then
			return {v1[1]/v2[1],v1[2]/v2[2],v1[3]/v2[3],v1[4]/v2[4]}
		else
			return {v1[1]/v2,v1[2]/v2,v1[3]/v2,v1[4]/v2}
		end
	end
	
	return API
end