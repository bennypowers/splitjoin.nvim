.PHONY: test

test:
	nvim --headless -u test/init.lua -c "lua local file = os.getenv('TEST_FILE') or 'test/'; require'plenary.test_harness'.test_directory(file, {minimal_init='test/init.lua',sequential=true})"
