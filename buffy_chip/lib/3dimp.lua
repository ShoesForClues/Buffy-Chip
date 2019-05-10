return function(thread)
	local API={
		_version={0,0,1};
		_dependencies={
			"stdlib";
			"parser";
			"openlg";
		};
		instances={};
	}
	
	function API:import_wavefront(data,properties)
		if type(data)=="string" then
			data=thread.libraries["parser"]:get_lines(data)
		end
		
		local mesh=thread.libraries["openlg"].objects.mesh(properties or {})
		
		for i,line in pairs(data) do
			local tokens=thread.libraries["parser"]:parse(line)
			if tokens[1]=="v" then
				mesh.vertices[#mesh.vertices+1]={tokens[2],tokens[3],tokens[4]}
			elseif tokens[1]=="vn" then
				mesh.normals[#mesh.normals+1]={tokens[2],tokens[3],tokens[4]}
			elseif tokens[1]=="vt" then
				mesh.texture_coordinates[#mesh.texture_coordinates+1]={tokens[2],tokens[3]}
			elseif tokens[1]=="f" then
				local v_data={
					thread.libraries["parser"]:split(tokens[2],"/",function(t) return tonumber(t) or 0 end);
					thread.libraries["parser"]:split(tokens[3],"/",function(t) return tonumber(t) or 0 end);
					thread.libraries["parser"]:split(tokens[4],"/",function(t) return tonumber(t) or 0 end);
				}
				mesh.faces[#mesh.faces+1]={
					vertices={v_data[1][1],v_data[2][1],v_data[3][1]};
					texture_coordinates={v_data[1][2],v_data[2][2],v_data[3][2]};
					normals={v_data[1][3],v_data[2][3],v_data[3][3]};
				}
			end
		end
		
		return mesh
	end
	
	return API
end