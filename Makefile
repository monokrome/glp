BUILD_PATH=build
LIB_PATH=lib/glp


bin/glp.js: ${BUILD_PATH} ${LIB_PATH} bin/glp.coffee node_modules build
	node_modules/.bin/coffee -o ${BUILD_PATH} -c bin/glp.coffee

	echo "#!/usr/bin/env node\n\n" > ${BUILD_PATH}/glp.temp.js
	cat ${BUILD_PATH}/glp.js >> ${BUILD_PATH}/glp.temp.js
	rm ${BUILD_PATH}/glp.js

	sed "s/..\\/src\\///g" ${BUILD_PATH}/glp.temp.js > $@
	# mv ${BUILD_PATH}/glp.temp.js $@

	# Tricking Make into thinking coffee was updated in case chmod fails
	touch bin/glp.coffee
	chmod +x $@
	touch $@


${LIB_PATH}: node_modules
	node_modules/.bin/coffee -o $@ -c src


node_modules: package.json
	npm install
	# Ensures that node_modules is always marked as new after installing
	touch node_modules


${BUILD_PATH}:
	mkdir $@


clean:
	rm -r ${BUILD_PATH}
	rm -r ${LIB_PATH}
	rm bin/glp.js


.PHONY: clean
