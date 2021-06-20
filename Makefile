example/rain.min.js: example/rain.js
	closure-compiler --js $< --js_output_file $@

example/rain.js: Main.elm
	elm make --optimize --output=$@ $<
