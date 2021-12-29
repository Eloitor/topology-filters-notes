#### CONFIGURATION ####

title = "Topology Filters Notes"
base_url = "eloitor.github.io/topology-filters-notes"

# Markdown files to include in the table of contents
content_files = "src/definitions.md src/structures.md"

#### END CONFIGURATION ####

.PHONY: all clean watch toc html_files copy_other_files docker

templates = $(shell find templates/ -type f -name '*.html')

##### Aviable targets to build #####

# Build the entire site
all: toc html_files copy_other_files

# Watch for changes in the src/ directory and rebuild the site
watch:
	make clean
	make all
	$(shell \
	while sleep 0.1; do echo 'src' | entr -d -z make all && \
		echo 'templates' | entr -d -z make all; \
	done)

# Build the entire site using a docker container
docker:
	$(shell \
	DOCKER_BUILDKIT=1 \
	docker build --pull --rm -f "Dokerfile" --output web .)

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
other_files_src = $(shell find src/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.css -o -iname \*.html \))
copy_other_files: $(patsubst src/%, web/%, $(other_files_src))

# Build an individual html file
web/%.html: src/%.md $(templates) templates/toc.html
	mkdir -p "$(@D)"
	pandoc --lua-filter=pandoc_filters/lean.lua \
		 -f markdown+pipe_tables-tex_math_dollars-raw_tex \
		--template templates/webpage.html \
		--css $(shell (echo $(patsubst web/%, %, $(@D)) | sed "s/[^/]*/./g"))/styles.css \
		-V root=$(shell (echo $(patsubst web/%, %, $(@D)) | sed "s/[^/]*/./g")) \
		--metadata title=${title} \
		--syntax-definition=lean_syntax.xml \
		--toc \
		--number-sections \
		$< -o $@

# Copy any non-html file from src/ to web/
web/%: src/%
	mkdir -p "$(@D)"
	cp $< $@

# Generate the table of contents
content_files_comma_separated = $(shell echo ${content_files} | sed 's/ /,/g')
templates/toc.html: $(subst ",,$(content_files))
	mkdir -p web

	pandoc -f markdown+pipe_tables-tex_math_dollars-raw_tex \
	-t html4 \
	--number-sections --file-scope \
	--toc-depth=2 \
	--toc -s $(subst ",,$(content_files)) > toc-tmp.html
	
	# Change all ocurrences of "nav" to "div"
	# sed -i 's/nav/div/g' toc-tmp.html

	pandoc -F pandoc_filters/fixtoc.py \
	 -s -f html -o templates/toc.html \
	 -M files=${content_files_comma_separated} \
	  toc-tmp.html

	# Remove everything but the table of contents
	sed -i '/<div id="TOC">/,/<\/div>/!d' templates/toc.html
