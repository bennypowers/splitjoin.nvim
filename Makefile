SHELL:=/usr/bin/env bash
.PHONY: test watch clean

clean:
	@rm -rf .test

watch:
	@echo "Testing..."
	@find . \
		-type f \
		-name '*.lua' \
		! -path "./.test/**/*" | entr -d make test

test:
	@nvim \
		--headless \
		--noplugin \
		-u test/bootstrap.lua \
		-c "PlenaryBustedDirectory test/ {minimal_init='test/init.lua',sequential=true,keep_going=false}" \
		-c "qa!"
