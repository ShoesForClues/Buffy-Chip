--[[************************************************************

	Neural Net Engine written by Jason Lee Copyright (c) 2018
	
	This software is free to use. You can modify it and 
	redistribute it under the terms of the MIT license.

--************************************************************]]

return function(thread)
	local API={
		_version={0,0,1};
		_dependencies={
			"stdlib";
		};
	}
	
	--::::::::::::::::::::[Logic Definitions]::::::::::::::::::::
	function API:multiplier_gate(x,y) return x*y end
	
	function API:adder_gate(x,y) return x+y end
	
	function API:sigmoid_gate(x) return 1/(1+thread.libraries["stdlib"].root_functions.math.exp(-x)) end
	
	function API:not_gate(x) return not x end
	
	function API:or_gate(x,y) return x or y end
	
	function API:and_gate(x,y) return x and y end
	
	function API:xor_gate(x,y) return API:and_gate(API:or_gate(x,y),API:or_gate(API:not_gate(x),API:not_gate(y))) end
	
	function API:xand_gate(x,y) return API:and_gate(x,API:not_gate(y)) end
	
	function API:max_gate(x,y) if x>=y then return x else return y end end
	
	function API:min_gate(x,y) if x<=y then return x else return y end end
	
	--::::::::::::::::::::[Create Neural Network]::::::::::::::::::::
	function API:create_neural_network(input_nodes,hidden_nodes,output_nodes)
		local network={
			layers={};
		}
		
		function network:add_layer(nodes)
			
		end
		
		return network
	end
	
	return API
end