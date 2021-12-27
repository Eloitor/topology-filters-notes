md_files = $(shell find src/ -type f -name '*.md')
html_files = $(patsubst src/%.md, web/%.html, $(md_files))
templates = $(shell find templates/ -type f -name '*.html')

other_files_src = $(shell find src/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.css -o -iname \*.html \))
other_files_web = $(patsubst src/%, web/%, $(other_files_src))

.PHONY: all clean auto init

# init:
# 	# Check if pandoc is installed
# 	# if [ ! -x $(which pandoc) ]; then
# 	# 	echo "pandoc is not installed. Please install it first."
# 	# 	exit 1
# 	# fi


all: $(html_files) $(other_files_web)

web/%.html: src/%.md $(templates)

	mkdir -p "$(@D)"
	pandoc --lua-filter=pandoc_filters/lean.lua \
		 -f markdown+pipe_tables-tex_math_dollars-raw_tex \
		--template templates/webpage.html \
		--css $(shell (echo $(patsubst web/%, %, $(@D)) | sed "s/[^/]*/./g"))/styles.css \
		-V root=$(shell (echo $(patsubst web/%, %, $(@D)) | sed "s/[^/]*/./g")) \
		--metadata title="Topology Filters Notes" \
		--syntax-definition=lean_syntax.xml \
		--toc \
		--number-sections \
		$< -o $@

web/%: src/%
	mkdir -p "$(@D)"
	cp $< $@

clean:
	rm -rf web

auto:
	make clean
	make all
	$(shell \
	while sleep 0.1; do echo 'src' | entr -d -z make all && \
		echo 'templates' | entr -d -z make all; \
	done)
