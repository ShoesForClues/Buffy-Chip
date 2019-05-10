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
	
	local finished=false
	
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
		source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/background_2.jpg",thread.scheduler.platform.enum.file_type.image);
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
	
	local snapcode=thread.libraries["gel"].elements.default_element({
		parent_element=gui;
		source=thread.scheduler.platform:load_source(args.main_dir.."/assets/textures/snapcodes.png",thread.scheduler.platform.enum.file_type.image);
		size={
			offset={x=0,y=0};
			scale={x=0.3,y=0};
		};
		background_color={r=0,g=0,b=0,a=1};
		source_color={r=1,g=1,b=1,a=0};
		wrapped=false;
		visible=true;
	})
	snapcode.position_constraint=thread.libraries["gel"].constraint:apply_center_position(snapcode,{offset={x=0,y=0},scale={x=0.25,y=0.15}})
	snapcode.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(snapcode,1,thread.libraries["gel"].enum.axis.x)
	
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.45,y=0.06}};
		size={offset={x=0,y=0},scale={x=0.5,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="Add me on snapchat!";
	})
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.45,y=0.1}};
		size={offset={x=0,y=0},scale={x=0.5,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="@ShoesForClues";
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.05,y=0.25}};
		size={offset={x=0,y=0},scale={x=0.9,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="I made this game in one day! But";
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.05,y=0.3}};
		size={offset={x=0,y=0},scale={x=0.9,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="hell, now I gotta do my geography";
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.05,y=0.35}};
		size={offset={x=0,y=0},scale={x=0.9,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="homework at midnight. But at least";
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.05,y=0.4}};
		size={offset={x=0,y=0},scale={x=0.9,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="y'all can play this flappy bird";
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.05,y=0.45}};
		size={offset={x=0,y=0},scale={x=0.9,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="ripoff while the slow elevator";
	})
	
	thread.libraries["gel"].elements.text_element({
		parent_element=gui;
		--source=thread.scheduler.platform:load_source("assets/textures/blank.png",thread.scheduler.platform.enum.file_type.image);
		visible=true;
		wrapped=true;
		background_color={r=0,g=0,b=0,a=1};
		position={offset={x=0,y=0},scale={x=0.05,y=0.5}};
		size={offset={x=0,y=0},scale={x=0.9,y=0.1}};
		font=thread.scheduler.platform:load_source(args.config.terminus,thread.scheduler.platform.enum.file_type.font);
		font_size=18;
		text_color={r=1,g=1,b=1,a=0};
		text_scaled=false;
		text_alignment={
			x=thread.libraries["gel"].enum.text_alignment.x.center;
			y=thread.libraries["gel"].enum.text_alignment.y.center;
		};
		text="comes down.";
	})
	
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
		text="BACK";
		font=thread.scheduler.platform:load_source(args.config.main_font,thread.scheduler.platform.enum.file_type.font);
		font_size=20;
		text_color={r=1,g=1,b=1,a=0};
		text_alignment={x=thread.libraries["gel"].enum.text_alignment.x.center,y=thread.libraries["gel"].enum.text_alignment.y.center}
	})
	button.position_constraint=thread.libraries["gel"].constraint:apply_center_position(button,{offset={x=0,y=0},scale={x=0.5,y=0.65}})
	button.size_constraint=thread.libraries["gel"].constraint:apply_size_ratio(button,52/128,thread.libraries["gel"].enum.axis.x)

	fade:bump_z_index()
	thread.libraries["geffects"]:tween_color(fade.background_color,{r=0,g=0,b=0,a=1},0.3,thread.libraries["easing"].inQuad)
	
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
	thread.libraries["geffects"]:tween_color(fade.background_color,{r=0,g=0,b=0,a=0},0.5,thread.libraries["easing"].inQuad)
	
	thread.parent_thread:create_thread(thread.scheduler.platform:require(args.main_dir.."/main_menu"),args)
	thread:delete()
	
	while thread.runtime:wait() do end
end