return function(thread)
	local API={
		_version={0,0,5};
		_dependencies={
			"stdlib";
			"gel";
		};
		elements={};
	}
	
	local text_buffer_element=thread.libraries["gel"].elements.default_element:extend() --::::::::::::::::::::[Text Buffer Element]::::::::::::::::::::
	function text_buffer_element:__tostring() return "text_buffer_element" end
	function text_buffer_element:new(properties)
		text_buffer_element.super.new(self,properties)
		
		self.char_size=thread.libraries["eztask"]:create_property(properties.char_size or {x=10,y=10})
		self.font=thread.libraries["eztask"]:create_property(properties.font)
		self.font_size=thread.libraries["eztask"]:create_property(properties.font_size or 16)
		self.text_color=thread.libraries["eztask"]:create_property(properties.text_color or {r=1,g=1,b=1,a=0})
		self.text_scaled=thread.libraries["eztask"]:create_property(properties.text_scaled or false)
		self.cursor_position=thread.libraries["eztask"]:create_property(properties.cursor_position or {x=1,y=1})
		self.max_lines=thread.libraries["eztask"]:create_property(properties.max_lines or 256)
		self.draw_position=thread.libraries["eztask"]:create_property({x=1,y=1})
	
		self.text_buffer={}
		
		self.binds[#self.binds+1]=self.absolute_size:attach(function() self:create_line_render() end)
		
		thread:create_thread(function(thread)
			while thread.runtime:wait(0.1) do
				self:create_line_render()
			end
		end)
	end
	
	function text_buffer_element:update_viewport()
		if #self.text_buffer>#self.child_elements.value then
			self.draw_position:set_value({x=self.draw_position.value.x,y=#self.text_buffer-#self.child_elements.value+1})
		else
			self.draw_position:set_value({x=self.draw_position.value.x,y=1})
		end
		for i,element in pairs(self.child_elements.value) do
			element.text:set_value(self.text_buffer[i+self.draw_position.value.y-1] or "")
		end
	end
	
	function text_buffer_element:create_line_render()
		for _,line in pairs(self.child_elements.value) do
			line:delete()
		end
		self.child_elements:set_value({})
		--self.super.get_absolute_size(self) --Stack overflow!?
		for i=1,thread.libraries["stdlib"].root_functions.math.floor(self.absolute_size.value.y/self.char_size.value.y) do
			thread.libraries["gel"].elements.text_element({
				parent_element=self;
				--source=thread.platform:load_source("assets/textures/blank.png",thread.platform.enum.file_type.image);
				visible=true;
				wrapped=true;
				background_color={r=0,g=0,b=0,a=1};
				position={offset={x=0,y=(i-1)*self.char_size.value.y},scale={x=0,y=0}};
				size={offset={x=0,y=self.char_size.value.y},scale={x=1,y=0}};
				font=self.font.value;
				font_size=self.font_size.value;
				text_color=self.text_color.value;
				text_scaled=self.text_scaled.value;
				text_alignment={
					x=thread.libraries["gel"].enum.text_alignment.x.left;
					y=thread.libraries["gel"].enum.text_alignment.y.top;
				};
				text="";
			})
		end
		self:update_viewport()
	end
	
	function text_buffer_element:clear()
		self.text_buffer={}
		self.draw_position:set_value({x=1,y=1})
		self.cursor_position:set_value({x=1,y=1})
		self:update_viewport()
	end
	
	function text_buffer_element:backspace(spaces)
		if spaces~=nil then
			for i=1,spaces do
				self.cursor_position:set_value({x=self.cursor_position.value.x-1,y=self.cursor_position.value.y})
				if self.cursor_position.value.x<1 then
					if self.cursor_position.value.y>1 then
						self.cursor_position:set_value({x=thread.libraries["stdlib"].root_functions.string.len(self.text_buffer[self.cursor_position.value.y-1] or ""),y=self.cursor_position.value.y-1})
					else
						self.cursor_position:set_value({x=1,y=1})
					end
				end
				self.text_buffer[self.cursor_position.value.y]=thread.libraries["stdlib"]:replace_string(self.text_buffer[self.cursor_position.value.y] or "",self.cursor_position.value.x," ")
			end
		end
	end
	
	function text_buffer_element:shift_lines(lines)
		if lines~=nil then
			for l=1,lines do
				for i=1,#self.text_buffer do
					self.text_buffer[i]=self.text_buffer[i+1] or ""
				end
			end
			self:update_viewport()
		end
	end
	
	function text_buffer_element:print(text,position)
		if text==nil then return end
		text=tostring(text)
		position=position or self.cursor_position.value
		self.text_buffer[position.y]=thread.libraries["stdlib"]:replace_string(self.text_buffer[position.y] or "",position.x,text)
		self.cursor_position:set_value({x=position.x+thread.libraries["stdlib"].root_functions.string.len(text),y=position.y})
		self:update_viewport()
	end
	
	function text_buffer_element:print_line(text)
		if text==nil then return end
		self:print(text)
		self.cursor_position:set_value({x=1,y=thread.libraries["stdlib"]:clamp(self.cursor_position.value.y+1,1,self.max_lines.value)})
		if #self.text_buffer>=self.max_lines.value then
			self:shift_lines(1)
		end
		--thread.platform:print(text)
	end
	
	API.elements.text_buffer_element=text_buffer_element
	
	return API
end