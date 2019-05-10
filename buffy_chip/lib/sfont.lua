--[[
Sprite Font API created by ShoesForClues
This API allows you to import custom fonts into roblox using a tool called Sprite Font Builder
You can download the software here: https://www.johnwordsworth.com/projects/sprite-font-builder/
--]]

return function(thread)
	local API={
		_version={0,1,0};
		_dependencies={
			"stdlib";
			"gel";
			"parser";
		};
	}
	
	function API:parse_line(line) --Parse .fnt data
		local tokens={}
		
		line=line.." "
		local text_len=thread.libraries["stdlib"].root_functions.string.len(line)
		
		local key,a="",1
		while a<text_len do
			local char=thread.libraries["stdlib"].root_functions.string.sub(line,a,a)
			if char~="=" then
				key=key..char
			else
				local value=""
				if thread.libraries["stdlib"].root_functions.string.sub(line,a+1,a+1)~='"' then
					local b=a+1
					while b<text_len do
						local sub_char=thread.libraries["stdlib"].root_functions.string.sub(line,b,b)
						if sub_char~=" " then
							value=value..sub_char
						else
							a=b
							break
						end
						b=b+1
					end
					tokens[key]=tonumber(value)
				else
					local b=a+2
					while b<text_len do
						local sub_char=thread.libraries["stdlib"].root_functions.string.sub(line,b,b)
						if sub_char~='"' then
							value=value..sub_char
						else
							a=b+1
							break
						end
						b=b+1
					end
					tokens[key]=value
				end
				key=""
			end
			a=a+1
		end
		
		return tokens
	end
	
	function API:load_font(data)
		local font={
			texture_id="";
			size=0;
			resolution=Vector2.new(0,0);
			line_height=0;
			base=0;
			characters={};
		}
		
		local parsed_data=thread.libraries["parser"]:get_lines(data)
		for i,v in pairs(parsed_data) do
			parsed_data[i]=API:parse_line(v)
		end
		
		font.texture_id=parsed_data[3]["file"]
		font.resolution=Vector2.new(parsed_data[2]["scaleW"],parsed_data[2]["scaleH"])
		font.size=parsed_data[1]["size"]/font.resolution.Y
		font.line_height=parsed_data[2]["common lineHeight"]/font.resolution.Y
		font.base=parsed_data[2]["base"]/font.resolution.Y
		
		for i=5,#parsed_data-1 do
			font.characters[parsed_data[i]["letter"]]={
				position=Vector2.new(parsed_data[i]["x"]/font.resolution.X,parsed_data[i]["y"]/font.resolution.Y);
				size=Vector2.new(parsed_data[i]["width"]/font.resolution.X,parsed_data[i]["height"]/font.resolution.Y);
				offset=Vector2.new(parsed_data[i]["xoffset"]/font.resolution.X,parsed_data[i]["yoffset"]/font.resolution.Y);
				x_advance=parsed_data[i]["xadvance"]/font.resolution.X
			}
		end
		
		return font
	end

	function API:create_sfont_image(properties)
		local sfont_image={
			properties=thread.libraries["stdlib"]:create_properties_table({
				font=thread.libraries["stdlib"]:create_property(properties.font,true);
				parent=thread.libraries["stdlib"]:create_property(properties.parent,true);
				name=thread.libraries["stdlib"]:create_property(properties.name or "sfont_image",true);
				visible=thread.libraries["stdlib"]:create_property(properties.visible or false,true);
				background_color_3=thread.libraries["stdlib"]:create_property(properties.background_color_3 or Color3.new(0,0,0),true);
				background_transparency=thread.libraries["stdlib"]:create_property(properties.background_transparency or 0,true);
				border_color_3=thread.libraries["stdlib"]:create_property(properties.border_color_3 or Color3.new(0,0,0),true);
				border_size_pixel=thread.libraries["stdlib"]:create_property(properties.border_size_pixel or 0,true);
				rotation=thread.libraries["stdlib"]:create_property(properties.rotation or 0,true);
				z_index=thread.libraries["stdlib"]:create_property(properties.z_index or 1,true);
				clips_descendants=thread.libraries["stdlib"]:create_property(properties.clips_descendants or false,true);
				text=thread.libraries["stdlib"]:create_property(properties.text or "",true);
				text_color_3=thread.libraries["stdlib"]:create_property(properties.text_color_3 or Color3.new(1,1,1),true);
				text_scaled=thread.libraries["stdlib"]:create_property(properties.text_scaled or false,true);
				text_size=thread.libraries["stdlib"]:create_property(properties.text_size or 14,true);
				text_stroke_color_3=thread.libraries["stdlib"]:create_property(properties.text_stroke_color_3 or Color3.new(0,0,0),true);
				text_stroke_transparency=thread.libraries["stdlib"]:create_property(properties.text_stroke_transparency or 1,true);
				text_transparency=thread.libraries["stdlib"]:create_property(properties.text_transparency or 0,true);
				text_wrapped=thread.libraries["stdlib"]:create_property(properties.text_wrapped or false,true);
				text_x_alignment=thread.libraries["stdlib"]:create_property(properties.text_x_alignment or Enum.TextXAlignment.Center,true);
				text_y_alignment=thread.libraries["stdlib"]:create_property(properties.text_y_alignment or Enum.TextYAlignment.Center,true);
				font_size=thread.libraries["stdlib"]:create_property(properties.font_size or Enum.FontSize.Size14,true);
				size=thread.libraries["stdlib"]:create_property(properties.size or UDim2.new(0,0,0,0),true);
				position=thread.libraries["stdlib"]:create_property(properties.position or UDim2.new(0,0,0,0),true);
			});
			render_size=Vector2.new(0,0);
			frame=nil;
			characters={};
		}
		
		sfont_image.frame=thread.libraries["bgui"]:create_frame(sfont_image.properties:extract())
		
		function sfont_image:update()
			if sfont_image.properties.font.value==nil then
				return
			end
			
			local text_len=thread.libraries["stdlib"].root_functions.string.len(sfont_image.properties.text.value)
			local current_position=Vector2.new(0,0)
			local current_char=1
			
			sfont_image.render_size=Vector2.new(0,0)
			for i=1,text_len do --Calculate the render size
				local c=sfont_image.properties.font.value.characters[thread.libraries["stdlib"].root_functions.string.sub(sfont_image.properties.text.value,i,i)]
				sfont_image.render_size=Vector2.new(sfont_image.render_size.X+c.x_advance,sfont_image.render_size.Y)
				if i==text_len then
					sfont_image.render_size=Vector2.new(sfont_image.render_size.X+c.size.X-c.x_advance+c.offset.X,sfont_image.render_size.Y)
				end
				if c.offset.Y+c.size.Y>sfont_image.render_size.Y then
					sfont_image.render_size=Vector2.new(sfont_image.render_size.X,c.offset.Y+c.size.Y)
				end
			end
			
			for i=1,text_len do
				local character=thread.libraries["stdlib"].root_functions.string.sub(sfont_image.properties.text.value,i,i)
				local c=sfont_image.properties.font.value.characters[character] or sfont_image.properties.font.value.characters[""]
				if character~=" " and c~=nil then
					local size=Vector2.new(1/c.size.X,1/c.size.Y)
					local position=Vector2.new(-size.X*c.position.X,-size.Y*c.position.Y)
					local scale=1/sfont_image.properties.font.value.size*sfont_image.properties.text_size.value
					
					if sfont_image.properties.text_scaled.value==true then
						scale=1/sfont_image.properties.font.value.size*sfont_image.frame.AbsoluteSize.Y
					end
					
					local char=sfont_image.characters[current_char]
					
					if char~=nil then
						char.Visible=true
						char.BackgroundTransparency=1
						char.ImageTransparency=sfont_image.properties.text_transparency.value
						char.ImageColor3=sfont_image.properties.text_color_3.value
						char.Image=sfont_image.properties.font.value.texture_id
						char.ImageRectOffset=c.position*sfont_image.properties.font.value.resolution
						char.ImageRectSize=c.size*sfont_image.properties.font.value.resolution
						char.Size=UDim2.new(0,scale*c.size.X,0,scale*c.size.Y)
						char.Position=UDim2.new(0,scale*(current_position.X+c.offset.X),0,scale*c.offset.Y)
						char.Parent=sfont_image.frame
						
						if sfont_image.properties.text_x_alignment.value==Enum.TextXAlignment.Center then
							char.Position=char.Position+UDim2.new(0.5,-(sfont_image.render_size.X*scale)/2,0,0)
						elseif sfont_image.properties.text_x_alignment.value==Enum.TextXAlignment.Right then
							char.Position=char.Position+UDim2.new(1,-sfont_image.render_size.X*scale,0,0)
						end
						if sfont_image.properties.text_y_alignment.value==Enum.TextYAlignment.Center then
							char.Position=char.Position+UDim2.new(0,0,0.5,-(sfont_image.properties.font.value.base*scale)/2)
						elseif sfont_image.properties.text_y_alignment.value==Enum.TextYAlignment.Bottom then
							char.Position=char.Position+UDim2.new(0,0,1,-sfont_image.properties.font.value.base*scale)
						end
					end
					
					current_position=Vector2.new(current_position.X+c.x_advance,0)
					current_char=current_char+1
				else
					current_position=Vector2.new(current_position.X+sfont_image.properties.font.value.characters[" "].x_advance,0)
				end
			end
		end
		
		function sfont_image:render()
			if sfont_image.properties.font.value==nil then
				for _,char in pairs(sfont_image.characters) do
					char:Destroy()
				end
				sfont_image.characters={}
				sfont_image.render_size=Vector2.new(0,0)
				return
			end
			
			local text_len=thread.libraries["stdlib"].root_functions.string.len(sfont_image.properties.text.value)
			local total_rendering=text_len-select(2,thread.libraries["stdlib"].root_functions.string.gsub(sfont_image.properties.text.value," ",""))
			
			for i=1,#sfont_image.characters-total_rendering do --Remove any excess rendered characters
				sfont_image.characters[i]:Destroy()
				thread.libraries["stdlib"].root_functions.table.remove(sfont_image.characters,i)
			end
			
			for i=1,total_rendering-#sfont_image.characters do --Create any additional rendered characters
				local character=thread.libraries["stdlib"].root_functions.string.sub(sfont_image.properties.text.value,i,i)
				local c=sfont_image.properties.font.value.characters[character]
				if character~=" " then
					sfont_image.characters[#sfont_image.characters+1]=thread.libraries["bgui"]:create_image_label({
						parent=sfont_image.frame;
					})
				end
			end
			
			sfont_image:update()
		end
		
		function sfont_image:delete()
			if sfont_image.frame~=nil then
				sfont_image.frame:Destroy()
			end
			sfont_image.characters={}
		end
		
		sfont_image:render()
		
		--Bind events so that rendering updates automatically
		sfont_image.properties.font:attach_bind(function(new,pre) sfont_image:update() end)
		sfont_image.properties.text_color_3:attach_bind(function(new,pre) sfont_image:update() end)
		sfont_image.properties.text_scaled:attach_bind(function(new,pre) sfont_image:update() end)
		sfont_image.properties.text_size:attach_bind(function(new,pre) sfont_image:update() end)
		sfont_image.properties.text_transparency:attach_bind(function(new,pre) sfont_image:update() end)
		sfont_image.properties.text_x_alignment:attach_bind(function(new,pre) sfont_image:update() end)
		sfont_image.properties.text_y_alignment:attach_bind(function(new,pre) sfont_image:update() end)
		
		sfont_image.properties.text:attach_bind(function(new,pre) sfont_image:render() end)
		sfont_image.frame.Changed:Connect(function() sfont_image:update() end)
		
		return sfont_image
	end
	
	return API
end