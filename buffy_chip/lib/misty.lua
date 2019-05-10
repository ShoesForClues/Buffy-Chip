return function(thread)
	local API={
		_version={0,3,2};
		_dependencies={
			"stdlib";
			"class";
			"http";
			"json";
		};
	}
	
	function API:init_robot(ip)
		local robot={
			ip=ip;
		}
		
		function robot:request(request_type,api,param)
			local request_body=thread.libraries["json"].encode(param)
			local response_body={}
			local res,code,response_headers=thread.libraries["http"].request{
				url="http://"..ip.."/api/"..api,
				method=request_type or "GET",
				headers={
					["Content-Type"]="application/x-www-form-urlencoded";
					["Content-Length"]=#request_body;
				},
				source=ltn12.source.string(request_body),
				sink=ltn12.sink.table(response_body),
			}
			for i,v in pairs(response_body) do
				response_body[i]=thread.libraries["json"].decode(v)
			end
			return {
				code=code;
				body=response_body;
			}
		end
		
		return robot
	end
	
	
	return API
end