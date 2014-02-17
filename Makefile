CC=coffee
IN=src

build_dir=build
dist_dir=lib

all: glp coverage

glp: ${dist_dir}/glp

${dist_dir}/glp: ${dist_dir}
	mkdir -p ${dist_dir}/glp
	${CC} -o "$@" -c "${IN}"

coverage: ${build_dir}/coverage.html

${build_dir}/coverage.html: ${build_dir}/coverage.js
	mocha --require ${build_dir}/coverage.js -R html-cov > $@
	make clean_coverage_sources

${build_dir}/coverage.js: ${build_dir} 
	./node_modules/.bin/coffeeCoverage \
		--initfile "$@" \
		--path relative \
		"${IN}" "${IN}"

${build_dir}:
	mkdir $@

${dist_dir}:
	mkdir -p ${dist_dir}

clean: clean_coverage_sources
	rm -rf "${build_dir}" "${dist_dir}"

clean_coverage_sources:
	find src -name \*.js -exec rm {} \;

.PHONY: glp glp_cov clean clean_coverage_sources coverage glp
