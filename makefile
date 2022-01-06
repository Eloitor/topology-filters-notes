#### CONFIGURATION ####
base_url = "https://eloitor.github.io/topology-filters-notes/"

# Markdown files to include in the table of contents (in order)
content_files = src/definitions.md src/structures.md

##### Aviable targets to build #####
.PHONY: all clean serve docker \
	toc html_files copy_other_files watch

# Build the entire site
all: toc html_files copy_other_files

# Build and serve the site locally (requires `browser-sync` and `entr`)
serve:
	@echo Serving the site locally...
	make clean
	make all base_url="http://localhost:3006/"
	browser-sync web& \
		make watch ACTION="make all base_url=http://localhost:3006/ && browser-sync reload"

# Build the entire site using a docker container (requires `docker`)
docker:
	$(shell \
	DOCKER_BUILDKIT=1 \
	docker build --pull --rm -f Dokerfile --output web .)

# Clean the site directory and remove the generated files
clean:
	rm -rf web
	rm -f templates/toc.html

#################################################################

# Generate the table of contents
toc: templates/toc.html

# Compile all .md files included in the src/ directory.
md_files = $(shell find src/ -type f -name '*.md')
html_files: $(patsubst src/%.md, web/%.html, $(md_files))

# Copy all other files from src/ to web/
other_files_src = $(shell find src/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.css -o -iname \*.html \
	-o -iname .htaccess -o -iname \*.ico -o -iname \*.js \))
copy_other_files: $(patsubst src/%, web/%, $(other_files_src))

# Build an individual html file
templates = $(shell find templates/ -type f -name '*.html') templates/toc.html
web/%.html: src/%.md $(templates)
	mkdir -p "$(@D)"

	# Extract yaml front matter from source ($<). This is only the text between the fist pair of --- lines.
	$(shell awk '/^---/{if (flag == 0) {flag = 1; next} else exit} flag' $< > tmp.yaml)

	pandoc \
		--css $(shell (echo $(patsubst web/%, %, $(@D)) | sed "s/[^/]*/./g"))/styles.css \
		-V root=$(shell (echo $(patsubst web/%, %, $(@D)) | sed "s/[^/]*/./g")) \
		--defaults=defaults.yaml \
		--defaults=tmp.yaml \
		$< -o $@

# Copy any non-html file from src/ to web/
web/%: src/%
	mkdir -p "$(@D)"
	cp $< $@

# Generate the table of contents
content_files_comma_separated = $(shell echo $(content_files) | sed 's/ /,/g')
templates/toc.html: $(content_files)
	mkdir -p web

	pandoc -f markdown+pipe_tables-tex_math_dollars-raw_tex \
	--toc --toc-depth=2 --number-sections --file-scope \
	-t html4 -s $(content_files) > toc-tmp.html
	
	pandoc -M base_url="$(base_url)" \
	 -F pandoc_filters/fixtoc.py \
	 -s -f html -o templates/toc.html \
	 -M files=$(content_files_comma_separated) \
	  toc-tmp.html

	# Remove everything but the table of contents
	sed -i '/<div id="TOC">/,/<\/div>/!d' templates/toc.html

# Watch for changes in the src/ directory and rebuild the site when changes are detected (requires `entr`)
# It can run additional tasks, passing the name of the task as the argument `ACTION`
ACTION = make all base_url=$(base_url)
files_to_watch = $(shell find src/ -type f  \( -iname \*.md -o -iname \*.html \)) $(shell find templates/ -type f -name '*.html')
watch:
	@echo Watching for changes in src/ and running $(ACTION) when changes are detected
	$(ACTION)
	while true; do \
		ls -d $(files_to_watch) | entr -d -p sh -c "$(ACTION)"; \
	done