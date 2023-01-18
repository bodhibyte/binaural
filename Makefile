# Note: Last built with version 2.0.15 of Emscripten

EMCC=emcc

SBAGEN_COMPILATION_FLAGS = \
	-DBUILD_EMSCRIPTEN \

EMFLAGS = \
	--memory-init-file 0 \
	-s RESERVED_FUNCTION_POINTERS=64 \
	-s ALLOW_TABLE_GROWTH=1 \
	-s EXPORTED_FUNCTIONS=@src/exported_functions.json \
	-s EXPORTED_RUNTIME_METHODS=@src/exported_runtime_methods.json \
	-s SINGLE_FILE=0 \
	-s NODEJS_CATCH_EXIT=0 \
	-s NODEJS_CATCH_REJECTION=0


EMFLAGS_ASM = \
	-s WASM=0

EMFLAGS_ASM_MEMORY_GROWTH = \
	-s WASM=0 \
	-s ALLOW_MEMORY_GROWTH=1

EMFLAGS_WASM = \
	-s WASM=1 \
	-s ALLOW_MEMORY_GROWTH=1

EMFLAGS_OPTIMIZED= \
	-Oz \
	# -flto \
	# --closure 1

# EMFLAGS_DEBUG = \
# 	-s ASSERTIONS=1 \
# 	-O1

BITCODE_FILES = out/sbagen.bc

SOURCE_API_FILES = src/api.js

OUTPUT_WRAPPER_FILES = src/shell-pre.js src/shell-post.js

EMFLAGS_PRE_JS_FILES = \
	--pre-js src/api.js

EXPORTED_METHODS_JSON_FILES = src/exported_functions.json src/exported_runtime_methods.json

all: optimized worker

.PHONY: optimized
optimized: dist/sbagen-wasm.js dist/sbagen-asm.js

dist/sbagen-wasm.js: $(BITCODE_FILES) $(OUTPUT_WRAPPER_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(EMFLAGS_WASM) $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@
	mv $@ out/tmp-raw.js
	cat src/shell-pre.js out/tmp-raw.js src/shell-post.js > $@
	rm out/tmp-raw.js

dist/sbagen-asm.js: $(BITCODE_FILES) $(OUTPUT_WRAPPER_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(EMFLAGS_ASM) $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@
	mv $@ out/tmp-raw.js
	cat src/shell-pre.js out/tmp-raw.js src/shell-post.js > $@
	rm out/tmp-raw.js


# html: dist/sbagen-wasm.html

# dist/sbagen-wasm.html: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
# 	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(EMFLAGS_WASM) $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

.PHONY: worker

worker: dist/worker.sbagen-wasm.js

dist/worker.sbagen-wasm.js: dist/sbagen-wasm.js src/worker.js
	cat $^ > $@

out/sbagen.bc: sbagen-src/
	cp src/sbagen-wasm.html dist/sbagen-wasm.html
	cp src/runhttp.py dist/runhttp.py
	mkdir -p out
	# Generate llvm bitcode
	$(EMCC) $(SBAGEN_COMPILATION_FLAGS) -c sbagen-src/sbagen.c -o $@

.PHONY: clean
clean:
	rm -f out/* dist/* cache/*