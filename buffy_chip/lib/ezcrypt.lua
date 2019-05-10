local len=string.len
local sub=string.sub
local char=string.char
local abs=math.abs
local floor=math.floor
local random=math.random

local function sign(v)
	if v<0 then
		return -1
	elseif v>0 then
		return 1
	end
	return 0
end

local function merge_tables(...)
	local tables,new_table={...},{}
	for _,current_table in pairs(tables) do
		for i,v in pairs(current_table) do
			new_table[#new_table+1]=v
		end
	end
	return new_table
end

local function sub_table(tbl,start_index,end_index)
	local sub_tbl={}
	for i=start_index,end_index do
		sub_tbl[#sub_tbl+1]=tbl[i]
	end
	return sub_tbl
end

local API={
	_version={0,0,8};
	_dependencies={};
	default={
		signature_size=8;
	};
};

function API:string_to_byte(data) --Converts UTF-8 to raw bytes
	if type(data)=="table" then return data end
	local output={}
	for i=1,len(data) do
		output[#output+1]=sub(data,i,i):byte()
	end
	return output
end

function API:byte_to_string(data) --Converts raw bytes to UTF-8
	if type(data)=="string" then return data end
	if type(data)=="number" then
		return char(data%255)
	elseif type(data)=="table" then
		local output=""
		for _,v in pairs(data) do
			if v>=0 and v<=255 then
				output=output..char(v)
			else
				output=output.."."
			end
		end
		return output
	end
end

function API:encode(data,key,direction)
	if data==nil or key==nil then return end
	direction=floor(direction or 0)
	if direction==0 then return data end
	local d_sign=sign(direction)
	local d_sign_abs=abs(d_sign)
	if type(data)=="string" then
		data=API:string_to_byte(data)
	end
	if type(key)=="string" then
		key=API:string_to_byte(key)
	end
	local output={}
	for i,v in pairs(data) do
		output[i]=(v+d_sign*key[(i+d_sign_abs-1)%#key+1])%256
	end
	return API:encode(output,key,direction-d_sign)
end

function API:encrypt(data,key)
	local key_len=0
	if type(key)=="string" then
		key_len=len(key)
	elseif type(key)=="table" then
		key_len=#key
	end
	local signature,signature_size={},API.default.signature_size
	for i=1,signature_size do signature[i]=random(0,255) end
	return API:encode(merge_tables(signature,data,signature),key,key_len)
end

function API:decrypt(data,key)
	local key_len=0
	if type(key)=="string" then
		key_len=len(key)
	elseif type(key)=="table" then
		key_len=#key
	end
	local signature_size=API.default.signature_size
	local output=API:encode(data,key,-key_len)
	local output_len=#output
	local output_string=API:byte_to_string(output)
	local success=sub(output_string,1,signature_size)==sub(output_string,output_len-signature_size+1,output_len)
	return sub_table(output,signature_size+1,output_len-signature_size),success
end
	
return API