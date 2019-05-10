local fusion=require("core/fusion")
fusion:setup(require("platform/love/0_11_2"))

fusion.scheduler:create_thread(fusion.platform:require("scripts/cela"),{
	auto_resize=false;
})

fusion.platform:initialize({
	screen_resolution={x=400,y=640};
	screen_mode=fusion.platform.enum.screen_mode.window;
	--screen_resolution=fusion.platform:get_max_resolution();
	--screen_mode=fusion.platform.enum.screen_mode.full_screen;
	frame_rate=60;
	cursor_visible=true;
	cursor_lock=false;
	window_title="Buffy Chip";
})

return 0