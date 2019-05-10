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
	thread:import("lib/sclib","sclib")
	
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
	
	local start_tick=nil
	local score=thread.libraries["eztask"]:create_property(0,true)
	local dead=thread.libraries["eztask"]:create_property(false,true)
	local pillars={}
	local finished=false
	
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
	
	local background_thread=thread:create_thread(function(t)
		t:import("lib/stdlib","stdlib")
		t:import("lib/geffects","geffects")
		t:import("lib/easing","easing")
		
		while dead.value==false and t.runtime:wait() do
			background.position:set_value({offset={x=0,y=0},scale={x=0,y=0}})
			t.libraries["geffects"]:tween_udim2(background.position,{offset={x=0,y=0},scale={x=-2.5,y=0}},10,t.libraries["easing"].linear)
		end
	end)
	
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
	chip.position_constraint=thread.libraries["gel"].constraint:apply_center_position(chip,{offset={x=0,y=0},scale={x=0.3,y=0.4}})
	chip.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(chip,1,thread.libraries["gel"].enum.axis.x)
	
	chip.velocity=thread.libraries["eztask"]:create_property(0,true)
	
	local score_label=thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0,y=0.1}};
		size={offset={x=0,y=0},scale={x=1,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
		font_size=36;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text=tostring(score.value);
	})
	
	score:attach(function(value)
		score_label.text:set_value(tostring(value))
	end)
	
	local idle_thread=thread:create_thread(function(t)
		t:import("lib/stdlib","stdlib")
		t:import("lib/geffects","geffects")
		t:import("lib/easing","easing")
		
		while start_tick==nil and t.runtime:wait() do
			t.libraries["geffects"]:tween_udim2(chip.position_constraint.position,{offset={x=0,y=0},scale={x=0.3,y=0.43}},0.5,t.libraries["easing"].inOutQuad)
			t.libraries["geffects"]:tween_udim2(chip.position_constraint.position,{offset={x=0,y=0},scale={x=0.3,y=0.4}},0.5,t.libraries["easing"].inOutQuad)
		end
	end)
	
	fade:bump_z_index()
	thread.libraries["geffects"]:tween_color(fade.background_color,{r=0,g=0,b=0,a=1},0.5,thread.libraries["easing"].inQuad)
	
	thread:link_bind(thread.scheduler.platform.mouse_key_state:attach(function(key_state)
		if dead.value==true then return end
		if key_state.key==1 and key_state.state==true then
			if start_tick==nil then
				start_tick=thread.runtime.current_tick
			end
			chip.velocity:set_value(args.config.jump_velocity)
		end
	end,thread))
	
	repeat thread.runtime:wait() until start_tick~=nil
	idle_thread:delete()
	
	local pillar_thread=thread:create_thread(function(a)
		a:import("lib/stdlib","stdlib")
		a:import("lib/eztask","eztask")
		a:import("lib/class","class")
		a:import("lib/gel","gel")
		while dead.value==false and a.runtime:wait(1.5) do
			local gap_position=thread.libraries["stdlib"]:clamp(thread.libraries["stdlib"].root_functions.math.random(1,70)/100,0.1,0.7-args.config.gap_size)
			local pillar=a.libraries["gel"].elements.default_element({
				parent_element=gui;
				size={
					offset={x=0,y=0};
					scale={x=0.2,y=1};
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
			pillar.top=a.libraries["gel"].elements.default_element({
				parent_element=pillar;
				source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/tree_top.png",thread.scheduler.platform.enum.file_type.image);
				size={
					offset={x=0,y=0};
					scale={x=1,y=0.5};
				};
				position={
					offset={x=0,y=0};
					scale={x=0,y=gap_position-0.5};
				};
				background_color={r=0,g=0,b=0,a=1};
				source_color={r=1,g=1,b=1,a=0};
				wrapped=true;
				visible=true;
			})
			pillar.bottom=a.libraries["gel"].elements.default_element({
				parent_element=pillar;
				source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/tree_bottom.png",thread.scheduler.platform.enum.file_type.image);
				size={
					offset={x=0,y=0};
					scale={x=1,y=0.5};
				};
				position={
					offset={x=0,y=0};
					scale={x=0,y=gap_position+args.config.gap_size};
				};
				background_color={r=0,g=0,b=0,a=1};
				source_color={r=1,g=1,b=1,a=0};
				wrapped=true;
				visible=true;
			})
			chip:bump_z_index()
			score_label:bump_z_index()
			pillar.thread=a:create_thread(function(t)
				t:import("lib/stdlib","stdlib")
				t:import("lib/geffects","geffects")
				t:import("lib/easing","easing")
				
				t:create_thread(function(c)
					while c.runtime:wait() do
						if pillar.position.value.scale.x<chip.position.value.scale.x then
							score:set_value(score.value+1)
							break
						end
					end
				end)
				
				t.libraries["geffects"]:tween_udim2(pillar.position,{offset={x=0,y=0},scale={x=-2.5,y=0}},10,t.libraries["easing"].linear)
				for i,p in pairs(pillars) do
					if p==pillar then
						t.libraries["stdlib"].root_functions.table.remove(pillars,i)
						break
					end
				end
			end)
			a.libraries["stdlib"].root_functions.table.insert(pillars,1,pillar)
		end
	end)
	
	while dead.value==false do
		local delay=thread.runtime:wait()
		chip.velocity:set_value(chip.velocity.value+(delay*args.config.gravity))
		chip.position_constraint.position:set_value({offset=chip.position_constraint.position.value.offset,scale={x=chip.position_constraint.position.value.scale.x,y=thread.libraries["stdlib"]:clamp(chip.position_constraint.position.value.scale.y+(chip.velocity.value*delay),0,1)}})
		
		for _,pillar in pairs(pillars) do
			if thread.libraries["gel"]:is_in_bounds({x=chip.absolute_position.value.x+(chip.absolute_size.value.x/2),y=chip.absolute_position.value.y+(chip.absolute_size.value.y/2)},pillar.top.wrap.value)==true then
				dead:set_value(true)
				break
			end
			if thread.libraries["gel"]:is_in_bounds({x=chip.absolute_position.value.x+(chip.absolute_size.value.x/2),y=chip.absolute_position.value.y+(chip.absolute_size.value.y/2)},pillar.bottom.wrap.value)==true then
				dead:set_value(true)
				break
			end
		end
		
		if chip.position_constraint.position.value.scale.y>=0.72 then
			--chip.position_constraint.position:set_value({offset=chip.position_constraint.position.value.offset,scale={x=chip.position_constraint.position.value.scale.x,y=0.72}})
			dead:set_value(true)
		end
	end
	background_thread:delete()
	pillar_thread:delete()
	
	while chip.position_constraint.position.value.scale.y<0.72 do
		local delay=thread.runtime:wait()
		chip.velocity:set_value(chip.velocity.value+(delay*args.config.gravity))
		chip.position_constraint.position:set_value({offset=chip.position_constraint.position.value.offset,scale={x=chip.position_constraint.position.value.scale.x,y=thread.libraries["stdlib"]:clamp(chip.position_constraint.position.value.scale.y+(chip.velocity.value*delay),0,1)}})
	end
	chip.position_constraint.position:set_value({offset=chip.position_constraint.position.value.offset,scale={x=chip.position_constraint.position.value.scale.x,y=0.72}})
	
	score_label.visible:set_value(false)
	
	if score.value>max_score then
		max_score=score.value
	end
	
	local complete_label=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/dialog_box.png",thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=0.6,y=0};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
	})
	complete_label.position_constraint=thread.libraries["gel"].constraint:apply_center_position(complete_label,{offset={x=0,y=0},scale={x=0.5,y=1.5}})
	complete_label.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(complete_label,83/128,thread.libraries["gel"].enum.axis.x)
	
	thread.libraries["gel"].elements.text_element({
		parent_element=complete_label;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0,y=0.16}};
		size={offset={x=0,y=0},scale={x=1,y=0.3}};
		font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
		font_size=24;
		text_color={r=1,g=1,b=0.4,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="SCORE: "..tostring(score.value);
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=complete_label;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0,y=0.38}};
		size={offset={x=0,y=0},scale={x=1,y=0.3}};
		font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
		font_size=24;
		text_color={r=1,g=0.4,b=0.4,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="TIME: "..tostring(thread.libraries["stdlib"]:round(thread.runtime.current_tick-start_tick,3));
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=complete_label;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0,y=0.6}};
		size={offset={x=0,y=0},scale={x=1,y=0.3}};
		font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
		font_size=24;
		text_color={r=0.4,g=1,b=0.4,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="RECORD: "..tostring(max_score);
	})
	
	thread.libraries["geffects"]:tween_udim2(complete_label.position_constraint.position,{offset={x=0,y=0},scale={x=0.5,y=0.4}},0.5,thread.libraries["easing"].outQuad)
	
	local button=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/button_1.png",thread.scheduler.platform.enum.file_type.image);
		size={offset={x=0,y=0},scale={x=0.25,y=0}};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=true;
		visible=true;
	})
	local button_title=thread.libraries["gel"].elements.text_element({
		parent_element=button;
		size={offset={x=0,y=0},scale={x=1,y=1}};
		background_color={r=0,g=0,b=0,a=1};
		wrapped=true;
		visible=true;
		text="NEXT";
		font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
		font_size=20;
		text_color={r=1,g=1,b=1,a=0};
		text_alignment={x=thread.libraries["gel"].enum.text_alignment.x.center,y=thread.libraries["gel"].enum.text_alignment.y.center}
	})
	button.position_constraint=thread.libraries["gel"].constraint:apply_center_position(button,{offset={x=0,y=0},scale={x=1.5,y=0.6}})
	button.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(button,52/128,thread.libraries["gel"].enum.axis.x)
	
	thread.libraries["geffects"]:tween_udim2(button.position_constraint.position,{offset={x=0,y=0},scale={x=0.5,y=0.6}},0.5,thread.libraries["easing"].outQuad)
	
	thread:link_bind(thread.scheduler.platform.mouse_key_state:attach(function(key_state)
		if finished==true then return end
		if key_state.key==1 and key_state.state==true and thread.libraries["gel"]:is_in_bounds(thread.scheduler.platform.mouse_position.value,button.wrap.value)==true then
			--button.source:set_value(thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/button_1.png",thread.scheduler.platform.enum.file_type.image))
			button.source_color:set_value({r=0.6,g=0.6,b=0.6,a=0.5})
			button_title.text_color:set_value({r=0.6,g=0.6,b=0.6,a=0.5})
			finished=true
		end
	end,thread))
	
	repeat thread.runtime:wait() until finished==true
	
	fade:bump_z_index()
	thread.libraries["geffects"]:tween_color(fade.background_color,{r=0,g=0,b=0,a=0},0.3,thread.libraries["easing"].inQuad)
	
	thread.parent_thread:create_thread(thread.scheduler.platform:require(args.main_dir.."/main_menu"),args)
	thread:delete()
	
	while thread.runtime:wait() do end
end