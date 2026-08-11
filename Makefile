docs/rain.min.js: docs/rain.js
	closure-compiler --js $< --js_output_file $@

docs/rain.js: RainMode.elm
	elm make --optimize --output=$@ $<
