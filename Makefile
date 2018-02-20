TIMESTAMP = $(shell date +%Y%m%d%H%M%S)

SRC_ADMINISTRATE_STYLE=administrate/blueprints/core/style

DIST=dist

DIST_ADMINISTRATE_DIR=$(DIST)/administrate
DIST_ADMINISTRATE_STYLE_DIR=$(DIST_ADMINISTRATE_DIR)/style
DIST_ADMINISTRATE_FONT_DIR=$(DIST_ADMINISTRATE_STYLE_DIR)/fonts

LESS_CMD=node_modules/less/bin/lessc

help:
	@echo HELP:
	@echo "  compile - to compile all the project"
	@echo "  compile_js - to compile JS code"
	@echo "  compile_style - to compile Style code"



#### Compile ##########################################################################################

compile: compile_js compile_style

compile_js: compile_js_src_modern compile_js_src

compile_style: administrate_style administrate_fonts


#### Clean ############################################################################################

clean:
	rm -rf $(DIST)

distclean: clean
	rm -rf bower_components/
	rm -rf node_modules/


#### Packages managers ################################################################################
bower_components: node_modules bower.json
	node_modules/bower/bin/bower --config.analytics=false --allow-root install
	touch bower_components/

node_modules: package.json
	-rm -rf node_modules/rig
	npm install
	touch node_modules/


#### Styles ###########################################################################################

dist_administrate:
	mkdir -p $(DIST_ADMINISTRATE_FONT_DIR)

administrate_style: dist_administrate bower_components
	$(LESS_CMD) \
		--include-path=node_modules:bower_components \
		$(SRC_ADMINISTRATE_STYLE)/style.less \
		$(DIST_ADMINISTRATE_STYLE_DIR)/style.css --clean-css="--s1 --advanced --compatibility=ie8"

administrate_fonts: dist_administrate node_modules administrate_bootstrap_fonts
	$(LESS_CMD) \
		--include-path=node_modules \
		$(SRC_ADMINISTRATE_STYLE)/fonts.less \
		$(DIST_ADMINISTRATE_STYLE_DIR)/fonts.css --clean-css="--s1 --advanced --compatibility=ie8"

administrate_bootstrap_fonts: dist_administrate node_modules
	cp -R node_modules/bootstrap/dist/fonts/ $(DIST_ADMINISTRATE_FONT_DIR)
	touch $(DIST_ADMINISTRATE_FONT_DIR)



#### JavaScript #######################################################################################
compile_js_src_modern: node_modules
	npm run transpile:production
	# TODO: IMPORTANT: Remove this second part
	cp -rf dist/transpiled src/transpiled

compile_js_src: bower_components node_modules compile_js_src_modern
	node_modules/grunt-cli/bin/grunt ngtemplates
	node_modules/requirejs/bin/r.js \
		-o administrate/blueprints/core/static/build.js \
		out=$(DIST)/main.min.js