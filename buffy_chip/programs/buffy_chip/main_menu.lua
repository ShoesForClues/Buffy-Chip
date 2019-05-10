return function(thread,args)
	thread:import("lib/stdlib","stdlib")
	thread:import("lib/eztask","eztask")
	thread:import("lib/parser","parser")
	thread:import("lib/class","class")
	thread:import("lib/gel","gel")
	thread:import("lib/geffects","geffects")
	thread:import("lib/audiolib","audiolib")
	thread:import("lib/tui","tui")
	thread:import("lib/easing","easing")
	
	local gui=thread.libraries["gel"].elements.default_element({
		parent_element=args.gui_environment;
		--source=page_thread.platform:load_source(config.background_image,page_thread.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=1,y=1};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
		delete_on_thread_kill=true;
	})
	
	local fade=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		size={
			offset={x=0,y=0};
			scale={x=1,y=1};
		};
		background_color={r=0,g=0,b=0,a=0};
		source_color={r=0,g=0,b=0,a=1};
		wrapped=false;
		visible=true;
	})
	
	local background=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		source=thread.scheduler.platform:load_source(args.config.background_image,thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=2.5,y=1};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
	})
	thread.libraries["gel"].elements.default_element({
		parent_element=background;
		source=thread.scheduler.platform:load_source(args.config.background_image,thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=1,y=1};
		};
		position={
			offset={x=0,y=0};
			scale={x=1,y=0};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
	})
	--thread.libraries["gel"].constraint:apply_size_ratio(background,16/9,thread.libraries["gel"].enum.axis.y)
	
	thread:create_thread(function(t)
		t:import("lib/stdlib","stdlib")
		t:import("lib/geffects","geffects")
		t:import("lib/easing","easing")
		
		while t.runtime:wait() do
			background.position:set_value({offset={x=0,y=0},scale={x=0,y=0}})
			t.libraries["geffects"]:tween_udim2(background.position,{offset={x=0,y=0},scale={x=-2.5,y=0}},10,t.libraries["easing"].linear)
		end
	end)
	
	local title=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		source=thread.scheduler.platform:load_source(args.config.title_image,thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=0.8,y=0};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
	})
	title.position_constraint=thread.libraries["gel"].constraint:apply_center_position(title,{offset={x=0,y=0},scale={x=0.5,y=0.2}})
	title.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(title,73/348,thread.libraries["gel"].enum.axis.x)
	
	local chip=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/chip_1.png",thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=0.15,y=0};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
	})
	chip.position_constraint=thread.libraries["gel"].constraint:apply_center_position(chip,{offset={x=0,y=0},scale={x=0.5,y=0.4}})
	chip.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(chip,1,thread.libraries["gel"].enum.axis.x)
	
	thread:create_thread(function(t)
		t:import("lib/stdlib","stdlib")
		t:import("lib/geffects","geffects")
		t:import("lib/easing","easing")
		
		while t.runtime:wait() do
			t.libraries["geffects"]:tween_udim2(title.position_constraint.position,{offset={x=0,y=0},scale={x=0.5,y=0.22}},0.5,t.libraries["easing"].inOutQuad)
			t.libraries["geffects"]:tween_udim2(title.position_constraint.position,{offset={x=0,y=0},scale={x=0.5,y=0.2}},0.5,t.libraries["easing"].inOutQuad)
		end
	end)
	
	thread:create_thread(function(t)
		t:import("lib/stdlib","stdlib")
		t:import("lib/geffects","geffects")
		t:import("lib/easing","easing")
		
		while t.runtime:wait() do
			t.libraries["geffects"]:tween_udim2(chip.position_constraint.position,{offset={x=0,y=0},scale={x=0.5,y=0.43}},0.3,t.libraries["easing"].inQuad)
			t.libraries["geffects"]:tween_udim2(chip.position_constraint.position,{offset={x=0,y=0},scale={x=0.5,y=0.4}},0.3,t.libraries["easing"].outQuad)
		end
	end)
	
	local c_info=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		source=thread.scheduler.platform:load_source(args.config.copyright_image,thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=0.8,y=0};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
	})
	c_info.position_constraint=thread.libraries["gel"].constraint:apply_center_position(c_info,{offset={x=0,y=0},scale={x=0.5,y=0.9}})
	c_info.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(c_info,58/1171,thread.libraries["gel"].enum.axis.x)
	
	local button_debounce,selected_button,selected_page=true,nil,nil
	
	local function create_button(text,position,page)
		local button=thread.libraries["gel"].elements.default_element({
			parent_element=gui;
			source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/button_1.png",thread.scheduler.platform.enum.file_type.image);
			size={offset={x=0,y=0},scale={x=0.25,y=0}};
			background_color={r=0,g=0,b=0,a=1};
			source_color={r=1,g=1,b=1,a=0};
			wrapped=true;
			visible=true;
			text=text;
			font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
			font_size=20;
			text_color={r=1,g=1,b=1,a=0};
			text_alignment={x=thread.libraries["gel"].enum.text_alignment.x.center,y=thread.libraries["gel"].enum.text_alignment.y.center}
		})
		local button_title=thread.libraries["gel"].elements.text_element({
			parent_element=button;
			size={offset={x=0,y=0},scale={x=1,y=1}};
			background_color={r=0,g=0,b=0,a=1};
			wrapped=true;
			visible=true;
			text=text;
			font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
			font_size=20;
			text_color={r=1,g=1,b=1,a=0};
			text_alignment={x=thread.libraries["gel"].enum.text_alignment.x.center,y=thread.libraries["gel"].enum.text_alignment.y.center}
		})
		button.position_constraint=thread.libraries["gel"].constraint:apply_center_position(button,position)
		button.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(button,52/128,thread.libraries["gel"].enum.axis.x)
		
		thread:link_bind(thread.scheduler.platform.mouse_key_state:attach(function(key_state)
			if button_debounce==true or selected_button~=nil then return end
			if key_state.key==1 and key_state.state==true and thread.libraries["gel"]:is_in_bounds(thread.scheduler.platform.mouse_position.value,button.wrap.value)==true then
				--button.source:set_value(thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/button_1.png",thread.scheduler.platform.enum.file_type.image))
				button.source_color:set_value({r=0.6,g=0.6,b=0.6,a=0.5})
				button_title.text_color:set_value({r=0.6,g=0.6,b=0.6,a=0.5})
				selected_button,selected_page=button,page
			end
		end,thread))
		
		return button
	end
	
	local buttons={
		create_button(
			"START",
			{offset={x=0,y=0},scale={x=0.5,y=0.6}},
			args.main_dir.."/game"
		);
		create_button(
			"ABOUT",
			{offset={x=0,y=0},scale={x=0.5,y=0.67}},
			args.main_dir.."/about"
		);
		create_button(
			"EXIT",
			{offset={x=0,y=0},scale={x=0.5,y=0.74}},
			args.main_dir.."/exit"
		);
	}
	
	fade:bump_z_index()
	thread.libraries["geffects"]:tween_color(fade.background_color,{r=0,g=0,b=0,a=1},0.5,thread.libraries["easing"].inQuad)
	button_debounce=false
	
	repeat thread.runtime:wait() until selected_button~=nil
	
	for _,button in pairs(buttons) do
		thread:create_thread(function(t)
			t:import("lib/stdlib","stdlib")
			t:import("lib/geffects","geffects")
			t:import("lib/easing","easing")
			t.libraries["geffects"]:tween_udim2(button.position_constraint.position,{offset={x=0,y=0},scale={x=-1,y=button.position.value.scale.y}},0.4,t.libraries["easing"].inQuad)
		end)
		thread.runtime:wait(0.1)
	end
	
	thread.libraries["geffects"]:tween_color(fade.background_color,{r=0,g=0,b=0,a=0},0.3,thread.libraries["easing"].inQuad)
	
	if selected_page~=nil then
		thread.parent_thread:create_thread(thread.scheduler.platform:require(selected_page),args)
		thread:delete()
	end
	
	while thread.runtime:wait() do end
end