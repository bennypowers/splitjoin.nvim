test: *
	nvim --headless -u test/init.lua -c "lua require'plenary.test_harness'.test_directory('test/', {minimal_init='test/init.lua',sequential=true})"
