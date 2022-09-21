.PHONY: postprocess

postprocess:
	# Inject the folder of non-generated code into the index.ts file
	echo "\nexport * from './nongen/nongen';" >> client/index.ts
	# Remove tsickle to avoid a peer dependency issue
	cd client && npm uninstall tsickle

generate: ./openapi.spec.yaml ./openapi.generate.yaml
	docker run --rm \
		-v ${PWD}:/work/input \
		-v ${PWD}/client:/work/output \
		-v ${PWD}/openapi.spec.yaml:/work/spec/openapi.spec.yaml \
		openapitools/openapi-generator-cli generate \
		-o /work/output \
		-c /work/input/openapi.generate.yaml

client/node_modules: generate postprocess
	cd ./client && npm install # TODO peer dependency issue

compile: generate postprocess client/node_modules
	cd ./client && npm run build
